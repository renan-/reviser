DROP TABLE IF EXISTS commentaires;
DROP TABLE IF EXISTS pages;
DROP TABLE IF EXISTS entrees;
DROP TABLE IF EXISTS auteurs;

CREATE TABLE IF NOT EXISTS `auteurs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(50) NOT NULL,
  `prenom` varchar(50) NOT NULL,
  `pseudo` varchar(50) NOT NULL,
  `mail` varchar(50) NOT NULL,
  `mdp` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Structure de la table `commentaires`
--

CREATE TABLE IF NOT EXISTS `commentaires` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `texte` text NOT NULL,
  `auteur` int(11) NOT NULL,
  `entree` int(11) NOT NULL,
  `date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `auteur` (`auteur`),
  KEY `entree` (`entree`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `entrees`
--

CREATE TABLE IF NOT EXISTS `entrees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(1000) NOT NULL,
  `date` datetime NOT NULL,
  `auteur` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `auteur` (`auteur`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `pages`
--

CREATE TABLE IF NOT EXISTS `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `entree` int(11) NOT NULL,
  `auteur` int(11) NOT NULL,
  `texte` text,
  `date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `entree` (`entree`),
  KEY `auteur` (`auteur`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

--
-- Contraintes pour les tables exportées
--

--
-- Contraintes pour la table `commentaires`
--
ALTER TABLE `commentaires`
  ADD CONSTRAINT `commentaires_ibfk_1` FOREIGN KEY (`auteur`) REFERENCES `auteurs` (`id`),
  ADD CONSTRAINT `commentaires_ibfk_2` FOREIGN KEY (`entree`) REFERENCES `entrees` (`id`);

--
-- Contraintes pour la table `pages`
--
ALTER TABLE `pages`
  ADD CONSTRAINT `entrees_ibfk_1` FOREIGN KEY (`auteur`) REFERENCES `auteurs` (`id`),
  ADD CONSTRAINT `pages_ibfk_1` FOREIGN KEY (`entree`) REFERENCES `entrees` (`id`);

--
-- Contraintes pour la table `entrees`
--
ALTER TABLE `entrees`
  ADD CONSTRAINT `entrees_ibfk_2` FOREIGN KEY (`auteur`) REFERENCES `auteurs` (`id`);

