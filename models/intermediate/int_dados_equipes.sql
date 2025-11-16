{{ config(
    unique_key='id_equipe',
    materialized='table',
    tags=['construtores']
) }}


SELECT
    r.id_equipe,
    SUM(COALESCE(r.pontos, 0) + COALESCE(s.pontos, 0)) AS pontos_totais_equipe,
    COUNT(*) FILTER (WHERE r.posicao = '1') AS vitorias,
    COUNT(*) FILTER (WHERE r.posicao IN ('1', '2', '3')) AS podios,
    COUNT(*) FILTER (WHERE r.posicao_largada = '1') AS pole_positions,
    COUNT(*) FILTER (WHERE r.posicao_largada IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10')) AS largadas_top10,
    COUNT(*) FILTER (WHERE r.posicao_largada::int > 10) AS largadas_fora_top10
FROM {{ ref('stg_resultados') }} AS r
LEFT JOIN {{ ref('stg_sprint') }} AS s
    ON
        s.id_corrida = r.id_corrida
        AND s.id_equipe = r.id_equipe
GROUP BY r.id_equipe
