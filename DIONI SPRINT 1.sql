
/* Comentario general: En la tabla transacciones hay un campo llamado declined. Indica si la transacción está realizada o no.
En aquellos ejercicios en los que se solicitan las ventas se han incluido sólo los que tienen el campo 0 en declined. Para
aquellos casos en que se solicitan el número de transacciones he tenido en cuenta todo.*/

# Nivell 1

/*Exercici 2  
 Utilitzant JOIN realitzaràs les següents consultes*/
 
 /*A - Llistat dels països que estan fent compres*/

# HACEMOS UN JOIN DE LAS TABLAS MEDIENTE CAMPO COMPANY ID PARA SABER QUÉ COMPAÑÍAS HAN COMPRADO Y SELECCIONAMOS EL PAÍS USANDO EL DISTINCT

SELECT DISTINCT company.country
FROM transactions.transaction
LEFT JOIN transactions.company
ON transaction.company_id = company.id;


/* B- Des de quants països es realitzen les compres.*/

# USANDO LA QUERY DEL APARTADO ANTERIOR, PROCEDEMOS A CONTAR CUANTOS PAISES COMPRAN CON EL COUNT DISTINCT.

SELECT COUNT(DISTINCT company.country)
FROM transactions.transaction
LEFT JOIN transactions.company
ON transaction.company_id = company.id;


/* C - Identifica la companyia amb la mitjana més gran de vendes.*/

/*PARTIENDO DEL JOIN DE LA TABLA ANTERIOR, MOSTRAMOS EL NOMBRE DE LA COMPAÑÍA Y EL IMPORTE DE LAS VENTAS A ESA COMPAÑÍA (TENIENDO EN CUENTA
SÓLAMENTE EN CUENTA AQUELLAS VENTAS QUE SE HAN REALIZADO (DECLINED = 0). FINALMENTE, AGRUPAMOS POR COMPAÑÍAS Y CALCULAMOS LA MEDIA DE LAS VENTAS, ASÍ OBTENDREMOS 
UN LISTADO CON LAS VENTAS PROMEDIO DE CADA CIA Y PODREMOS ELEGIR LA QUE TIENE MAYOR VALOR.*/

# 
SELECT company.company_name, AVG(transaction.amount) AS VENTAAVG
FROM transactions.transaction
LEFT JOIN transactions.company
ON transaction.company_id = company.id
WHERE transaction.declined = 0
GROUP BY company.company_name
ORDER BY 2 DESC
LIMIT 1;

/*Exercici 3 
Utilitzant només subconsultes (sense utilitzar JOIN)*/

/* A- Mostra totes les transaccions realitzades per empreses d'Alemanya.*/

# En este ejercicio, he tenido en cuenta todas las transaciones ( sin filtrar por la columna decline)

#SUBQUERY: DE LA TABLA COMPANY SELECCIONAMOS EL ID DE LAS EMPRESAS QUE SON ALEMANAS

SELECT company.id 
FROM transactions.company
WHERE company.country= "Germany"; 

# SOLUCIÓN 1 :  "WHERE IN" FILTRAMOS AQUELLAS EMPRESAS QUE SON ALEMANAS

SELECT transaction.id
FROM transactions.transaction
WHERE transaction.company_id  IN (	SELECT company.id 
									FROM transactions.company
									WHERE company.country= "Germany");
                                    
# SOLUCIÓN 2 : USANDO   "WHERE EXIST" FILTRAMOS AQUELLAS EMPRESAS QUE SON ALEMANAS

SELECT  transaction.id
FROM transactions.transaction
WHERE EXISTS (	SELECT company.id 
				FROM transactions.company
				WHERE company.country= "Germany" AND transaction.company_id  = company.id );



/* B _ Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.*/

# SUBQUERY: PARA OBTENERLA MEDIA DE TODAS LAS TRANSACCIONES (SIN FILTRAR POR DECLINE)

SELECT AVG(AMOUNT)
FROM transactions.transaction;


# CON ESTA BUSQUEDA TENEMMOS TODAS LAS TRANSACCIONES QUE SON MAYORES QUE LA MEDIA. 

SELECT transaction.id, company.company_name, transaction.amount
FROM transactions.transaction
LEFT JOIN transactions.company
ON transaction.company_id = company.id
WHERE  transaction.amount > (	SELECT AVG(AMOUNT)
								FROM transactions.transaction);

#Query final - DE LA QUERY ANTERIOR, USAMOS EL DISTINCT PARA LISTAR LAS EMPRESAS QUE HACEN TRANSACCIONES.

SELECT DISTINCT company.company_name
FROM transactions.transaction
LEFT JOIN transactions.company
ON transaction.company_id = company.id
WHERE  transaction.amount > (	SELECT AVG(AMOUNT)
								FROM transactions.transaction);

#Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

# SUBQUERY: SACAMOS UN LISTADO CON LAS EMPRESAS QUE HAN HECHO TRANSACCIONES (SIN FILTRAR POR COLUMNA DECLINE)

SELECT  DISTINCT transaction.company_id
FROM transactions.transaction;

#QUERY FINAL AMB NOT EXIST

SELECT * 
FROM transactions.company
WHERE NOT EXISTS (	SELECT  DISTINCT transaction.company_id
					FROM transactions.transaction
					WHERE transaction.company_id = company.id);
                    
# TODAS LAS EMPRESAS HAN TENIDO TRANSACCIONES

# Nivell 2

/*Exercici 1
Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
Mostra la data de cada transacció juntament amb el total de les vendes.*/

# SACAMOS DE LA FECHA EL DÍA CON LA FUNCION  DATE() Y AGRUPAMOS EN FUNCIÓN DE LOS DÍAS. FILTRAMOS POR CAMPO DECLINED.

SELECT DATE(transaction.timestamp) AS DAY , SUM(transaction.amount)
FROM transactions.transaction
WHERE transaction.declined = 0
GROUP BY DAY
ORDER BY 2 DESC
LIMIT 5;

/* Exercici 2
Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.*/

# UNIMOS LAS DOS TABLAS

SELECT *
FROM transactions.transaction
LEFT JOIN transactions.company
ON transaction.company_id = company.id;

#DE LA SELECCIÓN ANTERIOR, AGRUPAMOS POR PAÍS Y SACAMOS EL AVERAGE. COMO HABLA DE VENTAS, FILTRAMOS POR CAMPO DECLINED.

SELECT company.country, AVG(transaction.amount)
FROM transactions.transaction
LEFT JOIN transactions.company
ON transaction.company_id = company.id
WHERE transaction.declined =0
GROUP BY company.country
ORDER BY 2 DESC;

/* Exercici 3
En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes  publicitàries per a fer competència 
a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que
estan situades en el mateix país que aquesta companyia.*/

#COMO HABLAN DE TRANSACCIONES, NO FILTRAREMOS POR CAMPO DECLINED.


/* A Mostra el llistat aplicant JOIN i subconsultes.*/

#SUBQUERY: PARA SACAR EL PAÍS EN EL QUE ESTÁ LA COMPANÍA "Non Institute" . OBTENEMOS QUE ES DE UK.

SELECT company.country
FROM transactions.company
WHERE company.company_name = "Non Institute" ;

# HACEMOS UNA OTRA SUBQUERY PARA LISTAR LAS EMPRESAS QUE HAY EN EL REINO UNIDO.

SELECT company.company_name, company.country
FROM  transactions.company
WHERE  company.country = (	SELECT company.country
							FROM transactions.company
							WHERE company.company_name = "Non Institute");
                            
#CON ESTA QUERY DE ARRIBA HAREMOS UNA DERIVED TABLE ( LA CUAL INCLUYE UNA NESTED SUBQUERY) Y LA USAREMOS PARA FILTRAR  MEDIANTE UN INNER JOIN
                            
                            
SELECT  transaction.id, company.company_name, transaction.amount, company.country
FROM transactions.transaction
LEFT JOIN transactions.company
ON transaction.company_id = company.id
INNER JOIN 	(SELECT  company.company_name AS company_name  # Usamos el innerjoin para filtrar la select original
		FROM  transactions.company
		WHERE  company.country = (	SELECT company.country
									FROM transactions.company
									WHERE company.company_name = "Non Institute"))  AS subquery
ON  company.company_name = subquery.company_name;
                                    
/* B Mostra el llistat aplicant solament subconsultes.*/

#SUBQUERY: PARA SACAR EL PAÍS EN EL QUE ESTÁ LA COMPANÍA "Non Institute" . OBTENEMOS QUE ES DE UK.

SELECT company.country
FROM transactions.company
WHERE company.company_name = "Non Institute" ;


# COGEMOS LAS NESTED SUBQUERY DEL APARTADO DE ARRIBA Y LA PONEMOS EN EL WHERE IN.

SELECT  transaction.id, company.company_name, transaction.amount, company.country
FROM transactions.transaction
LEFT JOIN transactions.company
ON transaction.company_id = company.id
WHERE company.country  = (	SELECT company.country
							FROM transactions.company
							WHERE company.company_name = "Non Institute");
                            
/*Nivell 3*/

/*Exercici 1
Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un
valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021
i 13 de març del 2022. Ordena els resultats de major a menor quantitat.*/

# AL SER TRANSACCIONES, NO FILTRAMOS POR CAMPO DECLINED. 
#HACEMOS JOIN DE LAS DOS TABLAS. EN EL WHERE PONEMOS DOS CONDICIONES.
#PRIMERA CONDICIÓN, EL LIMITE DE FECHAS
#LA SEGUNGA EL LIMITE DEL IMPORTE

SELECT   company.company_name, company.phone, company.country, DATE(transaction.timestamp) ,transaction.amount
FROM transactions.transaction
LEFT JOIN transactions.company
ON transaction.company_id = company.id
WHERE  (transaction.amount BETWEEN 100 AND 200)   
AND  DATE(transaction.timestamp) IN ( "2021-04-29",  "2021-07-20", "2022-03-13");




/* Exercici 2
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi,
per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses,
però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis 
si tenen més de 4 transaccions o menys.*/

# AGRUPAMOS POR EMPRESA Y CALCULAMOS EL NÚMERO DE TRANSACCIÓNES QUE HA HECHO CADA EMPRESA. LUEGO FILTRAMOS LAS EMPRESAS QUE TENGAN MÁS DE CUATRO COMPRAR

SELECT   company.company_name, COUNT(*) AS NumDeTransacciones,
CASE
    WHEN COUNT(*) > 4 THEN "TIENE MÁS DE CUATRO TRANSACCIONES"
    ELSE "TIENE MENOS DE CUATRO TRANSACCIONES"
END AS comments
FROM transactions.transaction
LEFT JOIN transactions.company
ON transaction.company_id = company.id
GROUP BY company.company_name
ORDER BY 2 DESC;

# Dioni 17.41














