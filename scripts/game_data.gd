class_name GameData
extends RefCounted


const SHOPS := {
	"ferreteria": {
		"name": "Ferretería El Tornillo de Oro",
		"short": "Ferretería",
		"owner": "Don Aurelio",
		"owner_role": "dueño",
		"customer": "Doña Elvira",
		"customer_role": "arquitecta jubilada",
		"owner_lines": [
			"Mijo, qué bueno verlo. Llevo desde las siete con esta llave en la mano: el barrio amanece y ya todos quieren arreglar algo.",
			"Aquí lo que más se vende no son los tornillos, ¿sabe? Es la charla. La gente entra por un clavo y se queda media hora.",
			"El balcón de la señora del 32 lleva tres meses pidiendo estos pernos. Hoy sí lo dejamos como nuevo.",
			"Pase, pase. Con este sol la herramienta se calienta sola, pero el trabajo no se hace solo.",
		],
		"customer_lines": [
			"Yo dibujé media cuadra de este barrio, ¿sabe? Ahora vengo por bisagras y a ver cómo cambia.",
			"Esa cornisa de enfrente la hicieron en el 68. Si mira bien, todavía tiene la marca del andamio.",
			"Antes aquí había una tienda de telas. Olía a tiza y a café. Ahora huele a aceite de máquina, y también me gusta.",
		],
		"info": [
			"La fotógrafa de la esquina anda buscando quién reparta los volantes de su exposición.",
			"Doña Rosa vende empanadas a media cuadra y siempre está corriendo. Esa señora necesita mandados.",
			"Camila, en el café, conoce a todo el que pasa. Si quiere clientes, empiece por un tinto.",
		],
	},
	"papeleria": {
		"name": "Papelería Papel & Tinta",
		"short": "Papelería",
		"owner": "Doña Nelly",
		"owner_role": "dueña",
		"customer": "Sofía",
		"customer_role": "estudiante de fotografía",
		"owner_lines": [
			"Llegó en buen momento: se me acabó el papel de las invitaciones y la impresora amaneció de mal humor.",
			"Aquí la gente viene a imprimir lo que le importa: un cartel, una carta, la foto de la abuela.",
			"Mire esta pila de cartulina. Si se cae, me voy a llorar un rato largo.",
			"El barrio escribe mucho, ¿sabe? Y casi todo lo escribe aquí.",
		],
		"customer_lines": [
			"Estoy revelando fotos de la 27. A esta hora las fachadas se ponen color miel; no hay que editar nada.",
			"Si algún día quiere retratos para su negocio, me dice. Ando con la cámara en la mochila.",
			"Mi profesora dice que una calle se conoce caminándola. Yo digo que se conoce esperando la luz.",
		],
		"info": [
			"Sofía está armando una exposición de la cuadra. Conoce a medio barrio por la cámara.",
			"La droguería de la esquina recibe pedidos a domicilio todos los días. Ahí hay trabajo.",
			"Don Aurelio, en la ferretería, le puede presentar a cualquiera. Lleva cuarenta años aquí.",
		],
	},
	"cafeteria": {
		"name": "Café La Esquina",
		"short": "Cafetería",
		"owner": "Camila",
		"owner_role": "dueña",
		"customer": "Don Jorge",
		"customer_role": "taxista",
		"owner_lines": [
			"Tinto o aromática. Pero siéntese un rato, que la prisa se le quita a la primera.",
			"El café abre a las seis. Primero el panadero, después las señoras del mercado, y al final los que van tarde a todo.",
			"Esta esquina es la oficina del barrio. Aquí se arregla el mundo antes del mediodía.",
			"Le guardé un puesto junto a la ventana. Ahí se oye todo sin tener que preguntar.",
		],
		"customer_lines": [
			"Llevo veinte años parando en esta esquina. Aquí uno se entera de todo antes que en las noticias.",
			"El tinto de Camila no es el mejor de la ciudad. Es el mejor de esta esquina, y con eso me basta.",
			"Yo llevo a la gente a todas partes, pero siempre vuelvo aquí. Uno vuelve a donde lo saludan.",
		],
		"info": [
			"El taxista para aquí todas las mañanas. Ese señor conoce cada calle y cada atajo.",
			"La ferretería recibe pedidos de todas las obras del sector. Don Aurelio siempre necesita una mano.",
			"El taller de bicis de la 29 arregla a domicilio. Nunca tiene quién lleve los repuestos.",
		],
	},
}

const CLIENTS := [
	{"name": "Doña Rosa", "trade": "empanadas de la esquina"},
	{"name": "Beto", "trade": "cerrajería móvil"},
	{"name": "La peluquería de Marlen", "trade": "cortes a domicilio"},
	{"name": "Don Isma", "trade": "frutería del parque"},
	{"name": "El taller de bicis de la 29", "trade": "reparaciones a domicilio"},
	{"name": "La panadería La Espiga", "trade": "pedidos de pan"},
	{"name": "El kiosco de la plaza", "trade": "revistas y dulces"},
	{"name": "Doña Piedad", "trade": "costuras y remiendos"},
]

const SUCCESS_LINES := [
	"¿Mandados? Ah, usted es el que aparece cuando uno lo necesita. Le paso el dato de {client}: {trade}, y nunca tiene tiempo de ir hasta allá.",
	"Mire, le voy a hacer un favor. {client}, {trade}. Dígale que va de mi parte y no le va a cerrar la puerta.",
	"Le tengo cliente. {client}, {trade}. Es gente seria, pero con afán; si llega temprano, gana.",
]

const REPEAT_LINES := [
	"Ya le pasé la voz a {client}. Si me consigue otro cliente, yo le consigo el siguiente.",
	"Tranquilo, mijo, que ya lo recomendé. Ahora muéstrese, que el barrio está mirando.",
	"Ya hablé bien de usted. Vuelva mañana y verá cómo le llueven los mandados.",
]

const INFO_REPLIES := [
	"Anote eso. En esta cuadra, el que saluda come.",
	"Ahí tiene. La información no pesa y abre puertas.",
	"Eso se lo cuento porque se ve que es de los que caminan el barrio.",
]

const REP_TITLES := [
	{"min": 0, "title": "Recién llegado"},
	{"min": 10, "title": "Conocido en la cuadra"},
	{"min": 30, "title": "De confianza"},
	{"min": 60, "title": "El del barrio"},
]

const GOAL_CLIENTS := 5


static func shop_ids() -> Array:
	return SHOPS.keys()


static func rep_title(rep: int) -> String:
	var title: String = REP_TITLES[0]["title"]
	for level in REP_TITLES:
		if rep >= int(level["min"]):
			title = level["title"]
	return title
