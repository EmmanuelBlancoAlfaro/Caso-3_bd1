
=====================================================================================
Esta investigación tiene cómo propósito entender bien los mecanismos necesarios para realizar la db del juego Gathel de la mejor manera posible, porque ahorita mismo estamos mamando
======================================================================================

	TEMAS DE FINTECH:
	
	1. Patrón Ledger:
	
	Cuando uno tiene un sistema de balances en un base de datos y quiere actualizar el balance de una persona, es un error hacerlo de la siguiente manera:
	
		///
		UPDATE Usuarios SET BalancePuntos = BalancePuntos - 10 WHERE UsuarioID = 5;
		UPDATE Usuarios SET BalancePuntos = BalancePuntos + 10 WHERE UsuarioID = 8;
		///
		
	Esto debido a varios motivos:
	
		1. No hay un historial del por qué se realizaron los cambios en el balance del jugador, si el mae te pregunta por qué sus 100 puntos iniciales cambiaron, no habría manera de responderle certeramente
		
		2. Si el usuario hace dos clics inmediatos para apostar sus últimos 5 puntos, ambos procesos de apuesta podrían leerse y hacerse antes de que el sistema cambie de 5 puntos a 0, ocasionando que el usuario haga 2 apuestas (10 puntos) teniendo solo 5. FUN FACT: un mae se hizo millonario gracias a esta estupidez de error en una web de bitcoin jajaja
		
		3. Puede llegar a pasar que el sistema pete justo después de descontar el dinero al usuario A, pero antes de sumárselo al usuario B, entonces ese dinero queda en el limbo, como un puntero X que guardaba información y se elimina, esa información queda ahí en la nada. También se debe aplicar algo acá para los transactions, para evitar lo que el profe había dicho que asustaban xDD
		
	Todo esto se soluciona con el Patrón Ledger. Este patrón tiene una regla fundamental: "Todo movimiento de dinero implica sacar de una cuenta y meter en otra cuenta distinta. El dinero nunca se destruye ni se crea, solo se transfiere". CINE
	Por lo tanto, la suma de todos los movimientos de una transacción debe ser siempre exactamente cero
	
	Para que el dinero siempre vaya a algún lado, Gathel no solo tendrá cuentas de usuarios, sino también se necesitan crear cuentas de sistema en la db. Más o menos algo así:
	
		1. Cuenta de Emisión (Mint): De donde salen los 100 puntos iniciales que se regalan al registro. Su balance será siempre negativo
		
		2. Cuenta de Custodia (Escrow/Pool): Donde se guarda el dinero apostado mientras la proposición está activa y aún no hay ganador
		
		3. Cuenta de Comisiones (Revenue): Donde la plataforma Gathel acumula sus ganancias
	
	
	2. Sistemas de Apuestas Mutuas:
	
	Mae di, cuando se hacen apuestas, existen 2 sistemas, el de cuota fija y el de apuestas Mutuas
		
		1. Cuota Fija: Es el que se usa en los casinos que es el jugador apostando contra la casa. La casa define una probabilidad estática y asume el riesgo financiero si pierde
		
		2. Apuestas Mutuas: Los jugadores apuestan entre sí y meten su dinero en el pool. La casa no asume ningún riesgo financiero, solo está ahí para mediar, cobrar una comisión fija por el servicio y distribuir las ganancias entre los ganadores. Por lo que las ganancias que obtienen los ganadores no se sabe hasta que se cierren las predicciones y el premio fluctúa dependiendo de la cantidad de apostadores a favor y en contra. Mae como un Polymarket o las apuestas de partidos
		
	Para la distribución de las ganancias y el pozo neto se deben usar las siguientes variables para realizar los cálculos necesarios:
	
		1. P: Pozo total (Suma de todas las apuestas, ganadoras y perdedoras)
		
		2. Cp: Porcentaje de comisión para la plataforma Gathel
		
		3. Ce: Porcentaje de comisión para el jugador que ejecutó la proposición
		
		4. W: Sub-pozo ganador (la suma de las apuestas de quienes acertaron)
		
	Los cálculos siguen la siguiente secuencia:
	
		Paso 1: Extracción del "Vigorish" (comisiones)
		Antes de pagarle a nadie, el sistema retira las ganancias aseguradas. A esto se le llama Vigorish o Takeout y se calcula así:
			Ctotal = P * (Cp + Ce)
			
		Paso 2: Cálculo del Pozo neto
		Es la cantidad del dinero real o puntos que los ganadores se van a repartir:
			N = P - Ctotal
			
		Paso 3: Determinación del Dividendo (ROI)
		Para saber cuánto le toca a cada ganador por cada punto o dinero apostado, se calcula el dividendo R:
			R = N/W 
			
	Hay que tener cuidado cuando se hagan los cálculos del dividendo, casi siempre va a resultar con que será un número con múltiples decimales periodicos o infinitos, pero di esto no nos sirve, ya que las apuestas son con un número de puntos enteros y el dinero darlo con tantos decimales es ineficiente.
	Cuando pasan estas cosas, utilizaremos un sistema llamado Breakage. Este sistema define un tamaño de tick mínimo (esto se refiere a redondear). El pago siempre se redondea hacia el tick más cercano
	Ejemplo: Si un jugador gana 3.56 puntos solo se le dan 3 y si gana 14.4534 dolares, solo se le dan 14.45. La plata o puntos restantes se guarda en una cuenta especial de la plataforma (nos forramos)
	
	Hay 2 escenarios a tomar en cuenta, cuando hay 0 perdedores y cuando hay 0 ganadores.
	
		1. Cuando hay 0 perdedores: Si todos aciertan, según los cálculos, R será menor a 1 por lo que los ganadores recibirán menos dinero del que apostaron
		
		2. Cuando hay 0 ganadores: Si nadie acierta, Gathel se queda con el 100% de las ganancias apostadas
		
	