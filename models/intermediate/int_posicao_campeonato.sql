{{ config(
    unique_key='id_piloto',
    materialized='table',
    tags=['pilotos']
) }}

WITH pontos_corrida AS (
    SELECT
        r.id_piloto,
        c.ano_corrida,
        (COALESCE(r.pontos, 0) + COALESCE(s.pontos, 0)) AS pontos_corrida,
        ROW_NUMBER() OVER (
            PARTITION BY r.id_piloto, c.ano_corrida
            ORDER BY (COALESCE(r.pontos, 0) + COALESCE(s.pontos, 0)) DESC
        ) AS rn
    FROM {{ ref('stg_resultados') }} r
    LEFT JOIN {{ ref('stg_corridas') }} c ON r.id_corrida = c.id_corrida
    LEFT JOIN {{ ref('stg_sprint') }} s
        ON r.id_corrida = s.id_corrida
        AND r.id_piloto = s.id_piloto
),

pontos_validos AS (
    SELECT
        id_piloto,
        ano_corrida,
        SUM(pontos_corrida) AS pontos_no_ano
    FROM pontos_corrida
    WHERE
        (ano_corrida <= 1990 AND rn <= 11)
        OR
        (ano_corrida > 1990)
    GROUP BY id_piloto, ano_corrida
)

SELECT
    id_piloto,
    ano_corrida AS ano,
    pontos_no_ano,
    ROW_NUMBER() OVER (
        PARTITION BY ano_corrida
        ORDER BY pontos_no_ano DESC
    ) AS colocacao_no_campeonato
FROM pontos_validos
