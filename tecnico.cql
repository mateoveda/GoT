// Archivo para hacer cosas

//cargar los Personajes
LOAD CSV WITH HEADERS FROM 'file:///got-s2-nodes.csv' AS row
CREATE (:Personaje {
    id: row.Id,
    name: row.Label
});

//comprobar
MATCH (p:Personaje) 
RETURN p.id, p.name;

//cargar los relaciones
LOAD CSV WITH HEADERS FROM 'file:///got-s2-edges.csv' AS row
MATCH (source:Personaje {id: row.Source}),
      (target:Personaje {id: row.Target})
CREATE (source)-[:HABLA_CON {conversaciones: toInteger(row.Weight), season: toInteger(row.Season)}]->(target);

//comprobar
MATCH (p:Personaje)-[r:HABLA_CON]->(p2:Personaje) 
RETURN p, r, p2;

//Cargar las casas:
LOAD CSV WITH HEADERS FROM 'file:///got-s2-casas.csv' AS row
CREATE (:Casa {
    id: toInteger(row.Id),
    name: row.Label
});

//comprobar
MATCH (c:Casa) 
RETURN c.id, c.name;

//cargar los relaciones
LOAD CSV WITH HEADERS FROM 'file:///got-s2-Personajes-casa.csv' AS row
MATCH (source:Personaje {id: row.IdPersonaje}),
      (target:Casa {name: row.House})
CREATE (source)-[:ES_LEAL_A]->(target);

//comprobar
MATCH (p:Personaje)-[r:ES_LEAL_A]->(c:Casa) 
RETURN p,r,c;

// PREGUNTAS ANÁLISIS BÁSICO (15 preguntas mínimo):

// 1. ¿Cómo es el esquema general del grafo?
CALL db.schema.visualization

// 2. ¿Cuáles tipos de nodos existen y que atributos tienen?
CALL db.schema.nodeTypeProperties

// 3. ¿Cuáles tipos de relaciones existen y que atributos tienen?
CALL db.schema.relTypeProperties

// 4. ¿Cuántos Personajes existen?
MATCH (p:Personaje)
RETURN COUNT(p.id) AS Total_Personajes;

// 5. ¿Cuántas Casas existen?
MATCH (c:Casa)
RETURN COUNT(c.id) AS Total_Casas;

// 6. ¿Cuántas relaciones "HABLA_CON" existen?
MATCH (p)-[r:HABLA_CON]->(k)
RETURN COUNT(r) AS Total_HABLA_CON;

// 7. ¿Cuántas relaciones "ES_LEAL_A" existen?
MATCH (p)-[r:ES_LEAL_A]->(k)
RETURN COUNT(r) AS Total_ES_LEAL_A;

// 8. ¿Cuál es la suma toal de conversaciones?
MATCH (p)-[r:HABLA_CON]->(k)
RETURN SUM(r.conversaciones) AS Total_conversaciones;

// 9. ¿Cuál es el promedio de conversaciones?
MATCH (p)-[r:HABLA_CON]->(k)
RETURN AVG(r.conversaciones) AS Promedio_Conversaciones;

// 10. ¿Quiénes son los 5 personajes con más la mayor cantidad de conversaciones como atributo de HABLA_CON?
MATCH (p:Personaje)-[r:HABLA_CON]->(k:Personaje)
WITH p.id AS ID, COUNT(r) AS Cantidad_conversaciones
RETURN ID, Cantidad_conversaciones
ORDER BY Cantidad_conversaciones DESC
LIMIT 5;

// 11. ¿Cuáles son las casas que más gente leal tiene?
MATCH (p:Personaje)-[r:ES_LEAL_A]->(c:Casa)
WITH c.id AS ID, c.name AS nombre_casa, COUNT(r) AS Cantidad_Leales
RETURN ID, nombre_casa, Cantidad_Leales
ORDER BY Cantidad_Leales DESC
LIMIT 5;

// 12. ¿Cuántas Relaciones hay en Total?
MATCH (p)-[r]->(k)
RETURN COUNT(r) AS Total_relaciones;

// 13. ¿Cuál es el diámetro del grafo?
// En el PDF (se obtuvo con Gephi).

// 14. ¿Cuál es la densidad del grafo?
// En el PDF (se obtuvo con Gephi).

// 15. ¿Cuántas personas han hablado con un determinado personaje?
// 16. ¿Cuál es el promedio de conversaciones en una persona?
// 17. ¿Con cuántas personas habla 'DAENERYS'?
// 18. ¿Cuál es el nodo con mayor número de relaciones?
// 19. ¿Cuántos miembros tiene cada casa?
// 20. ¿Cuántas personas no son leales a una casa en Juego de Tronos?


// PREGUNTAS ANÁLISIS CENTRALIDAD (15 preguntas mínimo):
// 1. ¿Cuáles son los personajes con mayor Degree en el grafo?
// 2. ¿Cuáles son los nodos con menor Degree en el grafo?
// 3. ¿Cuál es la distribución del Degree de los nodos en la red?
// 4. ¿Cuáles son aquellos personajes con un mayor Closeness Centrality?
// 5. ¿Cuáles son aquellos personajes con un menor Closeness Centrality?
// 6. ¿Cuáles son aquellos personajes con un alto Betweenness Centrality?
// 7. ¿Cuáles son aquellos personajes con un alto Degree pero que no tienen un alto Betweenness Centrality?
// 8. ¿Cómo es la distribución del Betweenness centrality?
// 9. ¿Cuáles son aquellos personajes con mayor PageRank?
// 10. ¿Cuáles son aquellos personajes con un bajo Degree pero con un alto PageRank?
// 11. ¿Cuáles son aquellos personajes que tienen un alto Degree pero un bajo Page Rank?
// 12. ¿Cuáles son los personajes con menor PageRank?
// 13. Utilizando Articulation Point ¿Cuáles son aquellos personajes cuyo Articulation Point es True?
// 14. Utilizando Bridge ¿Cuáles son las relaciones frágiles en la red que, si se eliminan, fragmentarían la comunidad? 
// 15. ¿Cuál es la información de determinado personaje dado su ID?
// 16. ¿A qué Casa pertenecen los 10 Personajes con mayor Degree?
// 17. ¿A qué casa pertenecen los 10 personajes con mayor Closeness Centrality?
// 18. ¿A qué casa pertenecen los 10 personajes con mayor PageRank?
// 19. ¿Qué personaje es el que tiene un alto Betweenness centrality entre distintas casas?
// 20. ¿Cuáles son las casas con personaje con menor PageRank?


// PREGUNTAS ANÁLISIS DE COMUNIDAD:

// 1.TC ¿Cuáles son los personajes que pertenecen a una mayor cantidad de tríadas densamente conectadas, lo que indicaría una relación fuerte entre ellos?
// 2.TC ¿Cuáles son las casas más fuertes y más comunicadas?
// 3.TC ¿Cuáles son las triadas que existen en el Grafo? (COLLECT)
// 4.CCoef ¿Cuáles son los personajes que tienen el mayor coeficiente de agrupamiento?
// 5.(CCoef + D) ¿Cuáles son los personajes que, a pesar de estar en varias conexiones, tienen un bajo coeficiente de agrupamiento, lo que indicaría que sus conexiones no están interconectadas entre sí?
// 6.SCC ¿Cuántos componentes fuertemente conectados existen en la red y qué casas o facciones representan? ¿Podrían representar alianzas?
// 7.(SCC + Casas) ¿Cuáles casas no apoyan fuertemente ni a los Stark ni a los Lannister?
// 8.WCC ¿Cuántos componentes débilmente conectados existen en la red? ¿Podrían indicar futuras alianzas?
// 9.LP(label Propagation) Si asumimos que los personajes adoptan la lealtad predominante en su entorno inmediato, ¿qué casas o facciones podrían absorber a personajes inicialmente neutrales? ¿Qué alianzas se forman de manera natural en el grafo sin intervención explícita, según la propagación de etiquetas?
// 10.LP(Seed) ¿Cómo quedarían las alianzas si CERSEI predominara sobre sus Conversaciones?
// 11.LP(Seed) ¿Cómo quedarían las alianzas si ROBB predomina sobre sus conversaciones?
// 12.LM ¿Cuáles son las comunidades que existen y quienes son los que las componen?
// 13.(LM + CC) En base a las comunidades detectadas anteriormente ¿Cuáles son los mejores distribuidores de información por comunidad?
// 14.(LM + MMetric) ¿Existen personajes cuya lealtad no está clara porque están dentro de comunidades con baja modularidad, lo que sugiere conexiones ambiguas?
// 15.(MMetric) ¿Qué comunidades parecen ser artificialmente sostenidas por un solo personaje y colapsaría si este fuera eliminado? (usamos Modularity Metric)
// 16.K1C + LM ¿Qué personajes tienen la mayor cantidad de conexiones con múltiples grupos, actuando como posibles mediadores o traidores de cada posible alianza?
// 17.(LM + BC) ¿Existen personajes críticos en las comunidades, tales que al eliminarlos generarían que ciertas comunidades se vieran obligadas a desaparecer o dividirse? Esta pregunta trata de identificar comunidades que estén conectadas sin triángulos
// 18.(PR + LM) ¿Qué personajes son potencialmente aptos para unir dos comunidades distintas para una posible alianza? (usamos PageRank primero y luego vemos las comunidades de los nodos con los que se relaciona)
// 19.(LM + D) ¿Quiénes son los personajes más incomunicados de cada comunidad? ¿Por qué personajes habría que empezar a eliminar si quisiéramos estratégicamente dejar debilitada dicha alianza poco a poco?
// 20.(LM + Casas) ¿Qué grupos de personajes que no tienen casa pueden ser potenciales aliados de otro grupo?


//¿Cuáles son aquellas casas que son más propensas a traicionar a otras casas? ¿De qué casa son las personas a las que les llega comunicación de muchas casas?


