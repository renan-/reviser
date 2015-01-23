DROP TABLE IF EXISTS `utilisations`;
DROP TABLE IF EXISTS `urls`;
DROP TABLE IF EXISTS `membres`;

--
-- Base de données: `racurl`
--

-- --------------------------------------------------------

--
-- Structure de la table `membres`
--

CREATE TABLE IF NOT EXISTS `membres` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(64) NOT NULL,
  `prenom` varchar(64) NOT NULL,
  `pseudo` varchar(64) NOT NULL,
  `mail` varchar(64) NOT NULL,
  `mdp` varchar(40) NOT NULL,
  `activation` varchar(40) NOT NULL,
  `profil` varchar(16) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pseudo` (`pseudo`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `urls`
--

CREATE TABLE IF NOT EXISTS `urls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source` varchar(1024) NOT NULL,
  `courte` varchar(10) NOT NULL,
  `creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `auteur` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `courte` (`courte`),
  KEY `auteur` (`auteur`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `utilisations`
--

CREATE TABLE IF NOT EXISTS `utilisations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `url` (`url`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Contraintes pour les tables exportées
--

--
-- Contraintes pour la table `urls`
--
ALTER TABLE `urls`
  ADD CONSTRAINT `urls_ibfk_1` FOREIGN KEY (`auteur`) REFERENCES `membres` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION,
  ADD CONSTRAINT `urls_ibfk_2` FOREIGN KEY (`auteur`) REFERENCES `membres` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION;

--
-- Contraintes pour la table `utilisations`
--
ALTER TABLE `utilisations`
  ADD CONSTRAINT `utilisations_ibfk_1` FOREIGN KEY (`url`) REFERENCES `urls` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `utilisations_ibfk_2` FOREIGN KEY (`url`) REFERENCES `urls` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

