-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 06-09-2025 a las 12:24:18
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bdsena`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cita_medica`
--

CREATE TABLE `cita_medica` (
  `id_cita` int(11) NOT NULL,
  `id_paciente` int(11) NOT NULL,
  `id_medico` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cita_medica`
--

INSERT INTO `cita_medica` (`id_cita`, `id_paciente`, `id_medico`, `fecha`, `hora`) VALUES
(1, 1, 1, '2025-08-20', '24:21:02'),
(2, 4, 2, '2025-09-06', '10:47:22'),
(3, 5, 2, '2025-09-06', '08:47:22'),
(5, 6, 2, '2025-09-06', '12:09:00'),
(6, 6, 1, '2025-09-12', '17:11:00'),
(8, 6, 1, '2025-09-15', '10:42:00'),
(9, 6, 1, '2025-09-06', '09:32:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_formula`
--

CREATE TABLE `detalle_formula` (
  `id_detalle` int(11) NOT NULL,
  `id_formula` int(11) NOT NULL,
  `id_medicamento` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `dosis` varchar(100) DEFAULT NULL,
  `duracion` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalle_formula`
--

INSERT INTO `detalle_formula` (`id_detalle`, `id_formula`, `id_medicamento`, `cantidad`, `dosis`, `duracion`) VALUES
(1, 1, 1, 12, 'cada dia 8 horas cada una', '5 dias'),
(2, 3, 1, 1, '150gr', 'cada 5 dias'),
(3, 7, 2, 5, '500 mg', '5 dias');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `formula_medica`
--

CREATE TABLE `formula_medica` (
  `id_formula` int(11) NOT NULL,
  `id_cita` int(11) NOT NULL,
  `id_medico` int(11) NOT NULL,
  `id_paciente` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `observaciones` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `formula_medica`
--

INSERT INTO `formula_medica` (`id_formula`, `id_cita`, `id_medico`, `id_paciente`, `fecha`, `observaciones`) VALUES
(1, 1, 1, 1, '2025-08-20', NULL),
(2, 2, 2, 4, '2025-09-05', 'Se la toma o la hospitalizo ajjaja'),
(3, 2, 2, 4, '2025-09-05', 'muchas ....'),
(4, 6, 1, 6, '2025-09-06', NULL),
(7, 8, 2, 6, '2025-09-06', 'Se los toma o se muere');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `laboratorio`
--

CREATE TABLE `laboratorio` (
  `id_laboratorio` int(11) NOT NULL,
  `id_cita` int(11) NOT NULL,
  `id_paciente` int(11) NOT NULL,
  `id_medico` int(11) NOT NULL,
  `tipo_prueba` varchar(100) NOT NULL,
  `resultados` text DEFAULT NULL,
  `fecha` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `laboratorio`
--

INSERT INTO `laboratorio` (`id_laboratorio`, `id_cita`, `id_paciente`, `id_medico`, `tipo_prueba`, `resultados`, `fecha`) VALUES
(1, 1, 1, 1, 'Frotis puchainal', 'tiene sida', '2025-08-19'),
(2, 9, 6, 2, 'Examenes de sangre', 'NO TIENE SIDA', '2025-09-19');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `medicamento`
--

CREATE TABLE `medicamento` (
  `id_medicamento` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `concentracion` varchar(50) DEFAULT NULL,
  `presentacion` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `medicamento`
--

INSERT INTO `medicamento` (`id_medicamento`, `nombre`, `descripcion`, `concentracion`, `presentacion`) VALUES
(1, 'Acetaminofen', 'Para dolores', '150gr', 'Acetamimaifrien'),
(2, 'Paracetamol', 'Analgésico y antipirético', '500 mg', 'Tabletas'),
(3, 'Ibuprofeno', 'Antiinflamatorio y analgésico', '400 mg', 'Tabletas'),
(4, 'Amoxicilina', 'Antibiótico de amplio espectro', '500 mg', 'Cápsulas'),
(5, 'Loratadina', 'Antihistamínico para alergias', '10 mg', 'Tabletas');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `medico`
--

CREATE TABLE `medico` (
  `id_medico` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `especialidad` varchar(100) NOT NULL,
  `registro_profesional` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `medico`
--

INSERT INTO `medico` (`id_medico`, `id_usuario`, `especialidad`, `registro_profesional`) VALUES
(1, 2, 'Cardiologo', 'Cardiologo Vascular'),
(2, 3, 'Medico General', 'Registri');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`id_rol`, `nombre`) VALUES
(1, 'Usuario'),
(2, 'Medico');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL,
  `tipo_documento` enum('CC','TI','CE','PAS') NOT NULL,
  `documento` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `email` varchar(120) NOT NULL,
  `password` varchar(255) NOT NULL,
  `direccion` varchar(150) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `id_rol`, `tipo_documento`, `documento`, `nombre`, `apellido`, `email`, `password`, `direccion`, `telefono`, `fecha_nacimiento`) VALUES
(1, 1, 'CC', '112345678', 'Juan', 'Perez', 'juan.perez@gmail.com', 'JuanPerez', 'Calle 12 a sur', '3020487463', '2005-08-23'),
(2, 2, 'CC', '1234567654', 'Maria', 'Gutierrez', 'maria.gutierrez@gmail.com', '32121432', 'Calle 34', '37847594892', '1997-08-28'),
(3, 2, 'CC', '1234567890', 'Juan', 'Gonzales', 'juan.gonzales.gmail.com', '$2b$10$sH5Z/XFALJgNZHtbS/ZNXO0omwB9tyRwbj0LwFTQFCJV60tw3JG8W', 'Calle falsa 2', '3214567481', '2025-03-11'),
(4, 1, 'CC', '1033698983', 'julietn', 'florez', 'julieth@gmail.com', 'ccf8b4e1e81892b4fe0d940d283cae710f4d2da6f9eb6408537574fd70a280f1', 'calle 23', '1234567890', NULL),
(5, 1, 'CC', '1140914398', 'juan ', 'hernandez', 'juan@gmail.com', '$2b$10$yM2dOgLQ6atSGLqe/y1TDeZAyASKXf4zge.xXmdud3WjXF1/rp0mW', 'calle 21', '1234567891', NULL),
(6, 1, 'CC', '1033698985', 'peperoni', 'lopez', 'peperoni@gmail.com', '$2b$10$0C2LH94q7Xhr3X.L42Jw2uu0YwSZ2LmNq01aMf2lL/v2EC66WP0ta', 'calle 45', '1234567895', NULL),
(7, 1, 'CC', '1033698986', 'pepe', 'navajas', 'pepe@gmail.com', '$2b$10$6Bktkm0jMn62MouWWhgL6eFJ0LLzNDpdxeSBsIChNQlPELyN4eiBi', 'calle 2', '1234567889', NULL);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cita_medica`
--
ALTER TABLE `cita_medica`
  ADD PRIMARY KEY (`id_cita`),
  ADD KEY `id_paciente` (`id_paciente`),
  ADD KEY `id_medico` (`id_medico`);

--
-- Indices de la tabla `detalle_formula`
--
ALTER TABLE `detalle_formula`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `id_formula` (`id_formula`),
  ADD KEY `id_medicamento` (`id_medicamento`);

--
-- Indices de la tabla `formula_medica`
--
ALTER TABLE `formula_medica`
  ADD PRIMARY KEY (`id_formula`),
  ADD KEY `id_cita` (`id_cita`),
  ADD KEY `id_medico` (`id_medico`),
  ADD KEY `id_paciente` (`id_paciente`);

--
-- Indices de la tabla `laboratorio`
--
ALTER TABLE `laboratorio`
  ADD PRIMARY KEY (`id_laboratorio`),
  ADD KEY `id_cita` (`id_cita`),
  ADD KEY `id_paciente` (`id_paciente`),
  ADD KEY `id_medico` (`id_medico`);

--
-- Indices de la tabla `medicamento`
--
ALTER TABLE `medicamento`
  ADD PRIMARY KEY (`id_medicamento`);

--
-- Indices de la tabla `medico`
--
ALTER TABLE `medico`
  ADD PRIMARY KEY (`id_medico`),
  ADD UNIQUE KEY `registro_profesional` (`registro_profesional`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `documento` (`documento`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `id_rol` (`id_rol`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cita_medica`
--
ALTER TABLE `cita_medica`
  MODIFY `id_cita` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `detalle_formula`
--
ALTER TABLE `detalle_formula`
  MODIFY `id_detalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `formula_medica`
--
ALTER TABLE `formula_medica`
  MODIFY `id_formula` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `laboratorio`
--
ALTER TABLE `laboratorio`
  MODIFY `id_laboratorio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `medicamento`
--
ALTER TABLE `medicamento`
  MODIFY `id_medicamento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `medico`
--
ALTER TABLE `medico`
  MODIFY `id_medico` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `cita_medica`
--
ALTER TABLE `cita_medica`
  ADD CONSTRAINT `cita_medica_ibfk_1` FOREIGN KEY (`id_paciente`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `cita_medica_ibfk_2` FOREIGN KEY (`id_medico`) REFERENCES `medico` (`id_medico`);

--
-- Filtros para la tabla `detalle_formula`
--
ALTER TABLE `detalle_formula`
  ADD CONSTRAINT `detalle_formula_ibfk_1` FOREIGN KEY (`id_formula`) REFERENCES `formula_medica` (`id_formula`),
  ADD CONSTRAINT `detalle_formula_ibfk_2` FOREIGN KEY (`id_medicamento`) REFERENCES `medicamento` (`id_medicamento`);

--
-- Filtros para la tabla `formula_medica`
--
ALTER TABLE `formula_medica`
  ADD CONSTRAINT `formula_medica_ibfk_1` FOREIGN KEY (`id_cita`) REFERENCES `cita_medica` (`id_cita`),
  ADD CONSTRAINT `formula_medica_ibfk_2` FOREIGN KEY (`id_medico`) REFERENCES `medico` (`id_medico`),
  ADD CONSTRAINT `formula_medica_ibfk_3` FOREIGN KEY (`id_paciente`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `laboratorio`
--
ALTER TABLE `laboratorio`
  ADD CONSTRAINT `laboratorio_ibfk_1` FOREIGN KEY (`id_cita`) REFERENCES `cita_medica` (`id_cita`),
  ADD CONSTRAINT `laboratorio_ibfk_2` FOREIGN KEY (`id_paciente`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `laboratorio_ibfk_3` FOREIGN KEY (`id_medico`) REFERENCES `medico` (`id_medico`);

--
-- Filtros para la tabla `medico`
--
ALTER TABLE `medico`
  ADD CONSTRAINT `medico_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
