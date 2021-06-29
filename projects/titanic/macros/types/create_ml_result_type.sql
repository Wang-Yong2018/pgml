{% macro create_ml_result_type() %}
DO $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'type_ml_result') THEN
        create type type_ml_result as (
            ml_name text,
            score_type text,
            train_mean_score float4,
            test_mean_score float4,
            create_time timestamptz,
            x_col_names text[],
            x_rows integer,
            n_cv smallint,
            is_trained boolean,
            total_second float,
            clf_obj jsonb,
            trained_model bytea );
        END IF;
        --more types here...
    END$$;
{% endmacro %}