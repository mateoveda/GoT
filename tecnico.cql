// Archivo para hacer cosas

//cargar los nodos
LOAD CSV WITH HEADERS FROM 'file:///got-s2-nodes.csv' AS row
CREATE (:Personaje {
    id: row.Id,
    name: row.Label
});

//comprobar
MATCH (p:Personaje) RETURN p.id, p.name;

//cargar los aristas
LOAD CSV WITH HEADERS FROM 'file:///got-s2-edges.csv' AS row
MATCH (source:Personaje {id: row.Source}),
      (target:Personaje {id: row.Target})
CREATE (source)-[:HABLA_CON {conversaciones: toInteger(row.Weight), season: toInteger(row.Season)}]->(target);

//comprobar
MATCH (p:Personaje)-[r:HABLA_CON]->(p2:Personaje) RETURN p, r, p2;

// PREGUNTAS ANÁLISIS BÁSICO (15 preguntas):

// 1. ¿Cómo es el esquema general del gráfo?
// 2. ¿Cuáles tipos de nodos existen?
// 3. ¿Qué atributos tienen los nodos?
// 4. ¿Cuáles tipos de relaciones existen?
// 5. ¿Qué atributos tienen las relaciones?
// 6. ¿Cuántos Personajes hay?
// 7. ¿Cuántas relaciones hay?
// 8. ¿Cuál es el diámetro del grafo?
// 9. ¿Cuál es la densidad del grafo?
// 10. ¿Cuál es la ruta más corta entre Jon y Cersei?
// 11. ¿Cuantas personas han hablado con Tyron y Tywin?
// 12. ¿Cual es el promedio de conversaciones en una persona?
// 13. ¿Con cuantas personas habla 'DAENERYS'?
// 14. ¿Cuáles son los dos nodos que tienen la relacion con la mayor cantidad de conversaciones como atributo?
// 15. ¿Cuál es el nodo con mayor numéro de relaciones?



