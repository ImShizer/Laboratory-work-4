CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    user_role VARCHAR(20) NOT NULL CHECK (
        user_role IN ('Student', 'Teacher', 'Admin')
    ),
    student_group VARCHAR(10) CHECK (
        student_group ~ '^[A-ZА-ЯІЇЄ]{2}-[0-9]{2}$'
    ),
    department VARCHAR(100)
);

CREATE TABLE components (
    component_id SERIAL PRIMARY KEY,
    component_name VARCHAR(100) NOT NULL,
    technical_state VARCHAR(20) NOT NULL CHECK (
        technical_state IN ('Справний', 'Пошкоджений', 'Новий')
    ),
    component_type VARCHAR(30) NOT NULL,
    form_factor VARCHAR(20) CHECK (
        form_factor IN ('ATX', 'Micro-ATX', 'Mini-ITX')
        OR form_factor IS NULL
    ),
    architecture_type VARCHAR(50)
);

CREATE TABLE ar_markers (
    marker_id SERIAL PRIMARY KEY,
    component_id INTEGER NOT NULL UNIQUE REFERENCES components (
        component_id
    ) ON DELETE CASCADE,
    code_pattern VARCHAR(100) NOT NULL UNIQUE,
    spatial_coordinates VARCHAR(100) NOT NULL CHECK (
        spatial_coordinates ~ (
            '^\([-+]?[0-9]+\.?[0-9]*,\s*'
            || '[-+]?[0-9]+\.?[0-9]*,\s*'
            || '[-+]?[0-9]+\.?[0-9]*\)$'
        )
    )
);

CREATE TABLE models_3d (
    model_id SERIAL PRIMARY KEY,
    component_id INTEGER NOT NULL UNIQUE REFERENCES components (
        component_id
    ) ON DELETE CASCADE,
    geometry_data VARCHAR(255) NOT NULL
);

CREATE TABLE sockets (
    socket_id SERIAL PRIMARY KEY,
    motherboard_id INTEGER NOT NULL REFERENCES components (
        component_id
    ) ON DELETE CASCADE,
    socket_type VARCHAR(50) NOT NULL,
    physical_zone VARCHAR(50) NOT NULL
);

CREATE TABLE compatibility_rules (
    rule_id SERIAL PRIMARY KEY,
    socket_id INTEGER NOT NULL REFERENCES sockets (
        socket_id
    ) ON DELETE CASCADE,
    compatibility_status VARCHAR(20) NOT NULL CHECK (
        compatibility_status IN ('Сумісно', 'Помилка')
    ),
    error_text_hint VARCHAR(255)
);

CREATE TABLE assembly_results (
    result_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users (
        user_id
    ) ON DELETE CASCADE,
    rule_id INTEGER NOT NULL REFERENCES compatibility_rules (
        rule_id
    ) ON DELETE CASCADE,
    configuration_state VARCHAR(30) NOT NULL CHECK (
        configuration_state IN (
            'Вірно', 'Помилка топології', 'Неповне складання'
        )
    ),
    verification_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
