docker exec -it base-datos mysql -u eneto -p
USE app_db;

CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    correo VARCHAR(100),
    rol ENUM('admin', 'cliente', 'tecnico') DEFAULT 'cliente'
);

INSERT INTO usuarios (nombre, correo, rol) VALUES
('Juan Pérez', 'juan@example.com', 'cliente'),
('Ana Gómez', 'ana@example.com', 'admin'),
('Carlos Ruiz', 'carlos@example.com', 'tecnico');
