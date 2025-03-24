// Archivo para hacer cosas

//cargar los nodos
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

// PREGUNTAS ANÁLISIS BÁSICO (15 preguntas mínimo):

// 1. ¿Cómo es el esquema general del grafo?
// 2. ¿Cuáles tipos de nodos existen?
// 3. ¿Qué atributos tienen los nodos?
// 4. ¿Cuáles tipos de relaciones existen?
// 5. ¿Qué atributos tienen las relaciones?
// 6. ¿Cuántos Personajes hay?
// 7. ¿Cuántas relaciones hay?
// 8. ¿Cuál es el diámetro del grafo?
// 9. ¿Cuál es la densidad del grafo?
// 10. ¿Cuál es la ruta más corta entre Jon y Cersei?
// 11. ¿Cuántas personas han hablado con un determinado personaje?
// 12. ¿Cuál es el promedio de conversaciones en una persona?
// 13. ¿Cuál es la distribución de la cantidad de relaciones “HABLA_CON” que hay en el grafo?
// 14. ¿Con cuántas personas habla 'DAENERYS'?
// 15. ¿Cuáles son los cinco Personajes que tienen la relación con la mayor cantidad de conversaciones como atributo de HABLA_CON?
// 16. ¿Cuál es el nodo con mayor número de relaciones?


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





// PREGUNTA EXTRA: ¿Quiénes son los mejores distribuiddores de información por comunidad?

// Degree, Closeness, Betweenness, PageRank, Articulation Point, bridges, CELF
