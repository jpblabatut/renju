////////////////////////////////////////////////////////////////////////////////
//
//	COMMENTAIRES
  //
  //	Nom					renju.sce
  //	Auteur				Jérôme LABATUT 
  //	Date de création	2017-02-17
  //
  //	Version Scilab		5.5.2
  //	Module Atoms requis	Aucun
  //
  //	Objectif			Implémentation du jeu de Renju
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//	INITIALISATION
	
	funcprot(0)
	clearglobal()
	clear()
	
	xdel(winsid())
	tohome()
	clc()
	
	global JEU
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//	CONSTANTES
//
////////////////////////////////////////////////////////////////////////////////

function affecterParametres()
	global JEU
	
	// Paramètres du modèle (damier et joueurs)
		JEU.DAMIER.DIRECTIONS_NOMBRE = 8
		JEU.DAMIER.DIRECTIONS_ANGLES = ((1:JEU.DAMIER.DIRECTIONS_NOMBRE) - 1)'/JEU.DAMIER.DIRECTIONS_NOMBRE*2*%pi
		JEU.DAMIER.DIRECTIONS = round([cos(JEU.DAMIER.DIRECTIONS_ANGLES), sin(JEU.DAMIER.DIRECTIONS_ANGLES)])
		
		JEU.DAMIER.IMPOSSIBLE = [0, 0];
		
		JEU.ALGORITHME.Humain = 1;
		JEU.ALGORITHME.Robot =  2; // Choix aléatoire parmi les meilleures cases
		JEU.ALGORITHME.Robot1 = 3; // Choix déterministe parmi les meilleures cases
		
		JEU.ETAT.Inactif = 0;
		JEU.ETAT.Actif = 1;
		JEU.ETAT.Bloque = 2;
		
		RExt = 0.4;
		RMed = 0.25;
		RInt = 0.1;
		
		Croix.Code = 1;
		Croix.Algorithme = JEU.ALGORITHME.Humain;
		Croix.Etat = JEU.ETAT.Actif;
		Croix.Nom = "Croix";
		Croix.Adjectif = "cruciforme";
		
		xCroix = RInt/2*(sqrt(1 + 2*((RExt/RInt)^2 - 1)) + 1);
		yCroix = RInt/2*(sqrt(1 + 2*((RExt/RInt)^2 - 1)) - 1);
		Croix.X = 0.5 + [ RInt,   xCroix,   yCroix,	...
						  0,    - yCroix, - xCroix,	...
						- RInt, - xCroix, - yCroix,	...
						  0,      yCroix,   xCroix,	...
						  RInt						]';
		Croix.Y = 0.5 + [ 0,      yCroix,   xCroix,	...
						  RInt,   xCroix,   yCroix,	...
						  0,    - yCroix, - xCroix,	...
						- RInt, - xCroix, - yCroix,	...
						  0							]';
		Croix.CouleurRVB = [1, 0, 0];
		Croix.CouleurCode = color("red");
		
		Rond.Code = 2;
		Rond.Algorithme = JEU.ALGORITHME.Robot1;
		Rond.Etat = JEU.ETAT.Actif;
		Rond.Nom = "Rond";
		Rond.Adjectif = "rond";
		
		angle = (0:360)'/360*2*%pi;
		angle2 = flipdim(angle, 1);
		Rond.X = 0.5 + [RExt*cos(angle); RMed*cos(angle2)];
		Rond.Y = 0.5 + [RExt*sin(angle); RMed*sin(angle2)];
		Rond.CouleurRVB = [0, 0, 1];
		Rond.CouleurCode = color("blue");
		
		Triangle.Code = 3;
		Triangle.Algorithme = JEU.ALGORITHME.Robot1;
		Triangle.Etat = JEU.ETAT.Inactif;
		Triangle.Nom = "Triangle";
		Triangle.Adjectif = "triangulaire";
		
		angle = %pi/2 + [0, 2*%pi/3, 4*%pi/3, 2*%pi]';
		angle2 = flipdim(angle, 1);
		Triangle.X = 0.5 + [RExt*cos(angle); RMed*cos(angle2)];
		Triangle.Y = 0.5 + [RExt*sin(angle); RMed*sin(angle2)];
		Triangle.CouleurRVB = [0, 1, 0];
		Triangle.CouleurCode = color("green");
		
		Carre.Code = 4;
		Carre.Algorithme = JEU.ALGORITHME.Robot1;
		Carre.Etat = JEU.ETAT.Inactif;
		Carre.Nom = "Carre";
		Carre.Adjectif = "carré";
		
		angle = - %pi/4 + [0, %pi/2, %pi, 3*%pi/2, 2*%pi]';
		angle2 = flipdim(angle, 1);
		Carre.X = 0.5 + [RExt*cos(angle); RMed*cos(angle2)];
		Carre.Y = 0.5 + [RExt*sin(angle); RMed*sin(angle2)];
		Carre.CouleurRVB = [0, 0.5, 0.5];
		Carre.CouleurCode = color("yellow");
		
		JEU.JOUEURS = list(Croix, Rond, Triangle, Carre);
		JEU.JOUEURS_NOMBRE = length(JEU.JOUEURS);
	//
	
	// Paramètres des vues (interface, damier et bandeau)
		JEU.INTERFACE.Nom = "Interface";
		JEU.INTERFACE.Titre = "OXO/Tic-tac-toe/Morpion";
		JEU.INTERFACE.Position = [0, 0];
		JEU.INTERFACE.Taille = [700, 700];
		JEU.INTERFACE.CouleurRVB = [0.8 0.8 0.8];
		
		JEU.DAMIER.Position = [0, 0, 0.75, 0.75];
		JEU.DAMIER.Marges = [0, 0, 0, 0];
		
		JEU.DAMIER.Selection = 3;		//  3 - Clic gauche
		JEU.DAMIER.Confirmation = 4;	//  4 - Clic centre
		JEU.DAMIER.Annulation = 11;		// 11 - Double-clic centre
		
		JEU.CASE.X = [0; 1; 1; 0];
		JEU.CASE.Y = [0; 0; 1; 1];
		JEU.CASE.CouleurCode = color("white");
		JEU.CASE.CouleurRVB = [1 1 1];
		JEU.CASE.TaillePolice = 15;
		
		JEU.BANDEAU.Nom = "BandeauInformations";	
		JEU.BANDEAU.Position = [10 10 500 100];
		JEU.BANDEAU.TaillePolice = 12;
		JEU.BANDEAU.CouleurRVB = [0.7 0.7 0.7];
	//
	
	// Parametres des contrôleurs (menus, boutons et partie)
		JEU.MENUS.Nom11 = "SélectionNombreJoueurs";
		JEU.MENUS.Nom12 = "SélectionTaille";
		JEU.MENUS.Nom13 = "SélectionJoueurHumain";
		JEU.MENUS.Nom13Choix = ["SélectionJoueurHumainNoir";	...
								"SélectionJoueurHumainBlanc";	...
								"SélectionJoueurHumainRouge";	...
								"SélectionJoueurHumainBleu";	...
								"SélectionJoueurHumainViolet";	...
								"SélectionJoueurHumainJaune";	...
								"SélectionJoueurHumainVert";	...
								"SélectionJoueurHumainOrange"];
		
		JEU.BOUTONS.Nom15 = "ControleurPartie";
		JEU.BOUTONS.Nom25 = "ControleurAffichageProbabilités";
		JEU.BOUTONS.Nom35 = "ControleurDécimation";
		JEU.BOUTONS.Nom45 = "ArretPartie";
		JEU.BOUTONS.Nom55 = "SortieJeu";	
		
		JEU.BOUTONS.Espace = 0.2;
		JEU.BOUTONS.Bordure = 1/10*JEU.BOUTONS.Espace;
		JEU.BOUTONS.Taille = JEU.BOUTONS.Espace - 2*JEU.BOUTONS.Bordure;
		JEU.BOUTONS.Position = [JEU.BOUTONS.Bordure, JEU.BOUTONS.Bordure, JEU.BOUTONS.Taille, JEU.BOUTONS.Taille];
		
		JEU.BOUTONS.Position15 = [4*JEU.BOUTONS.Espace 4*JEU.BOUTONS.Espace 0 0] + JEU.BOUTONS.Position;
		JEU.BOUTONS.Position25 = [4*JEU.BOUTONS.Espace 3*JEU.BOUTONS.Espace 0 0] + JEU.BOUTONS.Position;
		JEU.BOUTONS.Position35 = [4*JEU.BOUTONS.Espace 2*JEU.BOUTONS.Espace 0 0] + JEU.BOUTONS.Position;
		JEU.BOUTONS.Position45 = [4*JEU.BOUTONS.Espace JEU.BOUTONS.Espace   0 0] + JEU.BOUTONS.Position;
		JEU.BOUTONS.Position55 = [4*JEU.BOUTONS.Espace 0 0 0] + JEU.BOUTONS.Position;
		
		JEU.BOUTONS.CouleurRVB = [0.9 0.9 0.9];
		JEU.BOUTONS.TaillePolice = 15;
		
		JEU.ETAT_PARTIE.ACTIVABLE = 10;							// Sélection à faire ou à confirmer
		JEU.ETAT_PARTIE.ACTIVE = 11;							// Partie en cours
		JEU.ETAT_PARTIE.BLOQUEE = 12;							// Partie bloquée : tous les joueurs sont bloqués
		JEU.ETAT_PARTIE.INTERROMPUE = 13;						// Partie interrompue par l'utilisateur
		JEU.ETAT_PARTIE.COMPLETEE = 14;							// Damier complété
		JEU.ETAT_PARTIE.GAGNEE = 15;							// Une direction remplie par un des joueurs
		JEU.ETAT_PARTIE.REINITIALISABLE = 16;					// Partie terminée : vainqueur affiché, effacage du damier en attente
		
		JEU.Partie.NombreParties = 1;	//5						// Nombre de parties d'affilée
		JEU.Partie.NombreJoueurs = 2;
		JEU.Partie.Taille = 7;
		JEU.Partie.Renju = 3;
		JEU.Partie.CodeHumain = 1;
		
		JEU.Partie.Etat = JEU.ETAT_PARTIE.ACTIVABLE;
		
		JEU.Partie.AffichageAide = 0;
		// 0 : pas d'affichage
		// 1 : tableau
		// 2 : matrices
		
		JEU.Partie.AffichageLignesRemplies = 0;
		// 0 : pas d'affichage
		// 1 : indices des lignes, colonnes et diagonales pleines
		
		JEU.Partie.Decimation = 0;
		// 0 : pas de sélection
		// 1 : sélection confirmée, à exécuter
		
		JEU.Partie.AffichageGrille = 1;
		// 0 : pas de grille
		// 1 : grille du morpion
		
		JEU.Partie.PAUSE = 250;
	//
endfunction

////////////////////////////////////////////////////////////////////////////////
//
//	FONCTIONS MODELE
  //
  //			Fonction principale du jeu
  //			Pose d'un pion dans une case jouable et retournement des pions 
  //			Enlèvement des pions sélectionnés
  //			Calcul d'une grille de départ de taille donnée
  //
  //	Joueur	Heuristique du robot aléatoire
  //	Joueur	Heuristique du robot déterministe
  //	Joueur	Calcul du tenseur de probabilités (de victoire)
  //	Joueur	Sélection d'une case par le joueur humain
  //	Joueur	Sélection d'un rectangle de cases à décimer
  //
  //	Arbitre	Calcul des cases jouables (coordonnées, score et "connectivité")
  //	Arbitre	Calcul du score d'une case (0 si elle n'est pas jouable)
  //	Arbitre	Calcul des effectifs par ordre décroissant
  //	Arbitre Mise à jour du damier
  //	Arbitre	Proclamation de victoire éventuelle
//
////////////////////////////////////////////////////////////////////////////////

function GrilleS = jouerPartie(Grille)
	global JEU
	
	JEU.Partie.Voisinages = calculerVoisinages(JEU.Partie.Taille)
	JEU.Partie.Etat = JEU.ETAT_PARTIE.ACTIVE;				// Activation de la partie
	for Code = 1:JEU.Partie.NombreJoueurs					// Activation de tous les joueurs sélectionnés
		JEU.JOUEURS(Code).Etat = JEU.ETAT.Actif;
	end
	JEU.Partie.CodeVainqueur = 0;
	Code = 1;
	
	while (JEU.Partie.Etat == JEU.ETAT_PARTIE.ACTIVE)		// Début de la boucle sur les critères d'arrêt de jeu
		Etat = JEU.JOUEURS(Code).Etat;						// Etat du joueur courant
		Algorithme = JEU.JOUEURS(Code).Algorithme;			// Algorithme du joueur courant
		
		if (JEU.Partie.Decimation == 1)						// Décimation des pions sélectionnés
			Grille = enleverPions(Grille, JEU.Selection)
			
			controlerDecimationPions()
		end
		
		if (Etat == JEU.ETAT.Actif)							// Affichage des cases jouables pour les joueurs actifs
			if (JEU.Partie.AffichageAide == 1)
				voirProbabilites(Grille, JEU.Partie.CodeHumain)				
				
				sleep(JEU.Partie.PAUSE)
			end
			if (JEU.Partie.AffichageAide == 2)
				voirProbabilites(Grille, Code)
				
				sleep(JEU.Partie.PAUSE)
			end
		end
		
		//													// Sélection du coup par le joueur courant s'il est actif ...
		if (Etat == JEU.ETAT.Actif)|(Etat == JEU.ETAT.Bloque)
			select Algorithme
			case JEU.ALGORITHME.Humain						// ... et humain (choix de l'utilisateur)
				Coup = jouerHumain(Grille, Code)
			case JEU.ALGORITHME.Robot						// ... et robot (choix aléatoire parmi les cases libres)
				Coup = choisirAuHasard(Grille)
			case JEU.ALGORITHME.Robot1						// ... et robot (choix aléatoire parmi les coups optimum)
				Coup = calculerCoupOptimum(Grille, Code)	// Coup optimum : coup de gain maximum ou sinon de nuisance maximum
			end
			
			if isequal(Coup, JEU.DAMIER.IMPOSSIBLE)
				JEU.JOUEURS(Code).Etat = JEU.ETAT.Bloque;
				Etat = JEU.JOUEURS(Code).Etat;
				
				voirDamier("Pions", Grille)					// Forçage de l'actualisation du bandeau 
				voirBandeau("PartieBloquée", Grille)
			else
				JEU.JOUEURS(Code).Etat = JEU.ETAT.Actif;
				Etat = JEU.JOUEURS(Code).Etat;
				
				voirDamier("Pions", Grille)					// Forçage de l'actualisation du bandeau 
				voirBandeau("CoupPossible", Grille, Code, Coup)
			end
		end
		
		if (Etat == JEU.ETAT.Actif)							// Si le joueur courant peut jouer au moins un coup
			Grille = jouerCoup(Grille, Code, Coup)			// Actualisation du damier
			
			NombreCouleurs = zeros(JEU.Partie.NombreDirections, JEU.Partie.NombreVoisinages);
			
			for CCode = 1:JEU.Partie.NombreJoueurs			// Recherche d'un éventuel vainqueur
				[NombreCases, NombreCasesVides, Probabilites] = calculerProbabilites(Grille, CCode, JEU.Partie.Voisinages)
				
				for d = 1:JEU.Partie.NombreDirections		// Balayage des directions
					for z = 1:JEU.Partie.NombreVoisinages	// Balayage des voisinages
						if (NombreCases(d, z) == JEU.Partie.Renju)
							JEU.Partie.CodeVainqueur = CCode;
							JEU.Partie.CodeDirection = d;
							JEU.Partie.CodeVoisinage = z;
						end
					end
				end
				
				NombreCouleurs = NombreCouleurs + (NombreCases ~= 0);
			end
			
			for d = 1:JEU.Partie.NombreDirections			// Recherche des directions bloquées
				for z = 1:JEU.Partie.NombreVoisinages		// Recherche des voisinages bloqués
					if (NombreCouleurs(d, z) > 1)
						mprintf("Voisinage  " + string(z) + " dans la direction " + string(d) + " bloqué\n")
						
						voirDamier("CasesSélectionVoisinage", JEU.Partie.Voisinages(d, :, z), color("grey"))
					end
				end					
			end
			mprintf("\n")			
			
			//												// Si il y a un vainqueur > Partie terminée
			if (JEU.Partie.CodeVainqueur ~= 0)
				JEU.Partie.Etat = JEU.ETAT_PARTIE.GAGNEE;
			end
			//												// Si toutes les directions sont bloquées > Partie bloquée
			if (prod(NombreCouleurs > 1) == 1)
				JEU.Partie.Etat = JEU.ETAT_PARTIE.BLOQUEE;
			end
			//												// Si le damier est rempli sans vainqueur > Partie bloquée
			if (JEU.Partie.CodeVainqueur == 0)&(prod(Grille ~= 0))
				JEU.Partie.Etat = JEU.ETAT_PARTIE.BLOQUEE;
			end
			
			sleep(JEU.Partie.PAUSE)
		end
		
		if (Code == JEU.JOUEURS_NOMBRE)						// Passage au joueur suivant
			Code = 1;
		else
			Code = Code + 1;
		end
		
		drawnow()
	end														// Fin de la boucle sur les critères d'arrêt de jeu
	
	GrilleS = Grille;
	
	select JEU.Partie.Etat
	case JEU.ETAT_PARTIE.INTERROMPUE then					// Partie interrompue 
		voirBandeau("PartieInterrompue", GrilleS)
		voirDamier("Pions", GrilleS)						// Forçage de l'actualisation du bandeau
	case JEU.ETAT_PARTIE.BLOQUEE then						// Partie bloquée (grille pleine sans vainqueurs)
		voirBandeau("PartieBloquée", GrilleS)
		voirDamier("Pions", GrilleS)						// Forçage de l'actualisation du bandeau 
	case JEU.ETAT_PARTIE.GAGNEE then						// Partie gagnée : annonce du vainqueur
		voirBandeau("PartieVictoire", GrilleS, JEU.Partie.CodeVainqueur, JEU.Partie.CodeDirection)
		
		JEU.Partie.Voisinage = JEU.Partie.Voisinages(JEU.Partie.CodeDirection, :, JEU.Partie.CodeVoisinage)
		voirDamier("CasesSélectionVoisinage", JEU.Partie.Voisinage, JEU.JOUEURS(JEU.Partie.CodeVainqueur).CouleurCode)
	end
endfunction
function GrilleS = jouerCoup(Grille, Code, Coup)
	GrilleS = Grille;
	
	if (Grille(Coup(1, 1), Coup(1, 2)) == 0)
		GrilleS(Coup(1, 1), Coup(1, 2)) = Code;
		
		voirDamier("Pions", GrilleS)							// Actualisation de la vue du damier
		voirBandeau("CoupPossible", Grille, Code, Coup)
	else
		voirBandeau("CoupImpossible", Grille)
	end
endfunction
function GrilleS = enleverPions(Grille, Rectangle)
	GrilleS = Grille;
	
	voirBandeau("Décimation", Grille, Rectangle)
	
	GrilleS(Rectangle(1, 1):Rectangle(2, 1), Rectangle(1, 2):Rectangle(2, 2)) = 0;
	
	voirDamier("Pions", GrilleS)
	voirDamier("CasesEffacées")
	voirInterface("DécimationTerminée")
endfunction

function Coup = calculerCoupOptimum(Grille, Code)
	global JEU
	
	ListeCoups = [];
	
	for CCode = 1:JEU.Partie.NombreJoueurs
		[NombreCases, NombreCasesVides, Probabilites] = calculerProbabilites(Grille, CCode, JEU.Partie.Voisinages)
		
		if (CCode == Code)&(length(ListeCoups) == 0)		// Choix des cases de plus grande probabilité de victoire pour le joueur Robot 
			if (max(Probabilites) > 0)						// (gagnantes si max(Probabilites) = 1)
				ListeCoups = find(Probabilites == max(Probabilites));
			end
		end
		if (CCode ~= Code)									// Choix des cases bloquantes pour les autres joueurs (prioritaire)
			if (sum(Probabilites == 1) > 0)
				ListeCoups = find(Probabilites == 1);		//[ListeCoups, find(Probabilites == 1)];	
			end
		end
	end
	if (length(ListeCoups) == 0)							// Si aucune case ne se distingue, choix des cases libres
		ListeCoups = find(Grille == 0);
	end
	
	indiceL = 1 + floor((length(ListeCoups) - 1)*rand());	// Choix au hasard parmi les cases de même valeur stratégique
	indice = ListeCoups(1, indiceL);
	
	Coup = [modulo((indice - 1), JEU.Partie.Taille) + 1, floor((indice - 1)/JEU.Partie.Taille) + 1];
endfunction
function Coup = choisirAuHasard(Grille)
	global JEU
	
	ListeCoups = find(Grille == 0);
	
	indiceL = 1 + floor((length(ListeCoups) - 1)*rand());
	indice = ListeCoups(1, indiceL);
	
	Coup = [modulo((indice - 1), JEU.Partie.Taille) + 1, floor((indice - 1)/JEU.Partie.Taille) + 1];
endfunction
function Coup = jouerHumain(Grille, Code)
	global JEU
	
	AttendreSelection = %T;
	
	while (AttendreSelection)
		Coup = JEU.DAMIER.IMPOSSIBLE;
		
		Reponse = xgetmouse();
		x = Reponse(1);
		y = Reponse(2);
		Action = Reponse(3);
		
		if (Action == JEU.DAMIER.Selection)
			Coup = [min(1 + floor(x), JEU.Partie.Taille), ...
					min(1 + floor(y), JEU.Partie.Taille)];
		end
		if (Coup ~= JEU.DAMIER.IMPOSSIBLE)
			CaseVide = (Grille(Coup(1, 1), Coup(1, 2)) == 0);
			
			if (CaseVide)
				AttendreSelection = %F;
			end
		end
	end
endfunction
function [Rectangle, SelectionEffectuee] = selectionnerRectangle(Mode)
	global JEU
	
	select Mode
	case "Humain" 												// Mode automatique : l'usager sélectionne
		ContinuerSelection = %T;
		NombreSelections = 0;
		Rectangle = JEU.DAMIER.IMPOSSIBLE;
		
		while (ContinuerSelection)
			[Action, x, y] = xclick();							// Force pause dans l'exécution de la partie
			
			NombreSelections = NombreSelections + 1;
			
			select Action
			case JEU.DAMIER.Selection then
				if (NombreSelections == 1)
					Liste = min(1 + floor([x, y]), JEU.Partie.Taille);
					
					Rectangle = [Liste; Liste];
				end
				if (NombreSelections > 1)
					Liste = [Liste; min(1 + floor([x, y]), JEU.Partie.Taille)];
					
					i = Liste(($ - 1):$, 1);
					j = Liste(($ - 1):$, 2);
					
					Rectangle = [[min(i), min(j)]; [max(i), max(j)]];
				end
				
				voirDamier("CasesEffacées")
				voirDamier("CasesSélectionRectangle", Rectangle, color("orange"))
			case JEU.DAMIER.Confirmation then
				ContinuerSelection = %F;
				SelectionEffectuee = %T;
			case JEU.DAMIER.Annulation then			
				ContinuerSelection = %F;
				SelectionEffectuee = %F;
			end
		end
	case "Aléatoire"											// Un joueur humain : décimation aléatoire
		i = fix(1 + JEU.Partie.Taille*rand(2, 1));
		j = fix(1 + JEU.Partie.Taille*rand(2, 1));
		
		Rectangle = [[min(i), min(j)]; [max(i), max(j)]];
		SelectionEffectuee = %T;
		
		voirDamier("CasesEffacées")
		voirDamier("CasesSélectionRectangle", Rectangle, color("red"))
	end
endfunction

function Voisinages = calculerVoisinages(Taille)
	global JEU
	
	VecteurC =  (1:JEU.Partie.Renju) - 1;
	VecteurL = ((1:JEU.Partie.Renju) - 1)*JEU.Partie.Taille;
	VecteurD = ((1:JEU.Partie.Renju) - 1)*(JEU.Partie.Taille + 1);
	VecteurE = ((1:JEU.Partie.Renju) - 1)*(JEU.Partie.Taille - 1);
	
	VoisinagesC = zeros(JEU.Partie.Taille, JEU.Partie.Renju, JEU.Partie.NombreVoisinages)
	VoisinagesL = zeros(JEU.Partie.Taille, JEU.Partie.Renju, JEU.Partie.NombreVoisinages)
	VoisinagesD = zeros(JEU.Partie.NombreVoisinages, JEU.Partie.Renju, JEU.Partie.NombreVoisinages)
	VoisinagesE = zeros(JEU.Partie.NombreVoisinages, JEU.Partie.Renju, JEU.Partie.NombreVoisinages)
	
	for x = 1:JEU.Partie.Taille
		for z = 1:JEU.Partie.NombreVoisinages
			Origine = 1 + (x - 1)*JEU.Partie.Taille + (z - 1);
			
			VoisinagesC(x, :, z) = Origine + VecteurC;
		end
	end
	for x = 1:JEU.Partie.Taille
		for z = 1:JEU.Partie.NombreVoisinages
			Origine = 1 + (x - 1) + (z - 1)*JEU.Partie.Taille;
			
			VoisinagesL(x, :, z) = Origine + VecteurL;
		end
	end
	for x = 1:JEU.Partie.NombreVoisinages
		for z = 1:JEU.Partie.NombreVoisinages
			Origine = 1 + (x - 1)*JEU.Partie.Taille + (z - 1);
			
			VoisinagesD(x, :, z) = Origine + VecteurD;
		end
	end
	for x = 1:JEU.Partie.NombreVoisinages
		for z = 1:JEU.Partie.NombreVoisinages
			Origine = JEU.Partie.Renju + (x - 1) + (z - 1)*JEU.Partie.Taille;
			
			VoisinagesE(x, :, z) = Origine + VecteurE;
		end
	end
	
	Voisinages = [VoisinagesC; VoisinagesL; VoisinagesD; VoisinagesE];
endfunction
function [NombreCases, NombreCasesVides, Probabilites] = calculerProbabilites(Grille, Code, Voisinages)
	global JEU
	
	Probabilites = zeros(size(Grille, 1), size(Grille, 2));
	
	for d = 1:JEU.Partie.NombreDirections
		for z = 1:JEU.Partie.NombreVoisinages
			//												// Nombre de cases occupées par voisinage
			NombreCases(d, z) = sum(Grille(Voisinages(d, :, z)) == Code);
		
			//												// Nombre de cases vides par voisinage
			NombreCasesVides(d, z) = sum(Grille(Voisinages(d, :, z)) == 0);
		end
	end
	for d = 1:JEU.Partie.NombreDirections
		for z = 1:JEU.Partie.NombreVoisinages
			//												// Recherche des voisinages sans cases de couleur différente
			if (NombreCasesVides(d, z) ~= 0)&(NombreCases(d, z) + NombreCasesVides(d, z) == JEU.Partie.Renju)
				Probabilites(Voisinages(d, :, z)) = Probabilites(Voisinages(d, :, z)) + 1/NombreCasesVides(d, z);
			end
		end
	end
	for l = 1:JEU.Partie.Taille
		for c = 1:JEU.Partie.Taille
			if (Grille(l, c) ~= 0)							// Elimination des cases déjà occupées
				Probabilites(l, c) = 0;
			end
		end
	end
endfunction
function [Effectifs, Codes] = calculerEffectifs(Grille)
	global JEU
	
	Effectifs = [];
	
	for Code = 1:JEU.Partie.NombreJoueurs
		Effectifs = [Effectifs; sum(Grille == Code)];
	end
	
	[Effectifs, Codes] = gsort(Effectifs);
endfunction

////////////////////////////////////////////////////////////////////////////////
//
//	FONCTIONS VUES
  //
  //	Interface	Gestion des menus de sélection et des boutons d'action
  //	Damier		Gestion de l'affichage du damier, des cases et des pions 
  //	Bandeau		Messages d'information dans le bandeau
//
////////////////////////////////////////////////////////////////////////////////

function voirInterface(Action)
	global JEU
	
	select Action
	case "Création" then
		// Création de l'interface
			interfaceJeu = figure('figure_position', JEU.INTERFACE.Position)
			interfaceJeu.Tag = JEU.INTERFACE.Nom;
			
			interfaceJeu.figure_size = JEU.INTERFACE.Taille;
			interfaceJeu.auto_resize = 'on';
			interfaceJeu.figure_name = JEU.INTERFACE.Titre;
			interfaceJeu.backgroundcolor = JEU.INTERFACE.CouleurRVB;
			
			delmenu(interfaceJeu.figure_id, gettext('File'))
			delmenu(interfaceJeu.figure_id, gettext('?'))
			delmenu(interfaceJeu.figure_id, gettext('Tools'))
			toolbar(interfaceJeu.figure_id, 'off')
		//
		// Création du damier
			voirDamier("Création", JEU.Partie.Taille)
			voirDamier("Initialisation", JEU.Partie.Taille)
		//
		// Création du bandeau d'information
			voirBandeau("Création", [])
			voirBandeau("Initialisation", [])
		//
		
		// Menu de sélection du nombre de joueurs
			menu1 = uimenu(interfaceJeu, "Tag", JEU.MENUS.Nom11, "Label", "Nombre de joueurs");
			
			uimenu(menu1, "Label", "2 joueurs", "Callback", "selectionnerNombre(2)")
			uimenu(menu1, "Label", "3 joueurs", "Callback", "selectionnerNombre(3)")
			uimenu(menu1, "Label", "4 joueurs", "Callback", "selectionnerNombre(4)")
		//
		// Menu de sélection de la taille de la grille
			menu2 = uimenu(interfaceJeu, "Tag", JEU.MENUS.Nom12, "Label", "Tailles");
			
			for taille = 8:2:20
				uimenu(menu2,	"Label",	string(taille) + " x " + string(taille),	...
								"Callback",	"selectionnerTaille(" + string(taille) + ")")
			end
		//
		// Menu de sélection du joueur humain		// Pas plus d'un niveau d'arborescence pour les pointeur
			menu3 = uimenu(interfaceJeu, "Tag", JEU.MENUS.Nom13, "Label", "Joueur humain");
			
			uimenu(menu3, "Label", "Aucun", "Callback", "selectionnerHumain(0)")
			uimenu(menu3, "Label", "")
			
			for code = 1:JEU.JOUEURS_NOMBRE
				uimenu(menu3,	"Tag",		JEU.MENUS.Nom13Choix(code),					...
								"Label", 	JEU.JOUEURS(code).Nom,						...
								"Callback", "selectionnerHumain(" + string(code) + ")")
			end					
		//
		
		// Commande de lancement de la partie
			bouton15 = uicontrol(interfaceJeu, "style", "pushbutton");
			bouton15.Tag = JEU.BOUTONS.Nom15;
			bouton15.Units = "normalized";
			bouton15.Position = JEU.BOUTONS.Position15;
			bouton15.FontSize = JEU.BOUTONS.TaillePolice;
			bouton15.String = "Jouer";
			bouton15.BackgroundColor = JEU.BOUTONS.CouleurRVB;
			bouton15.Callback = "controlerPartie()";
			bouton15.Relief = "raised";
		//
		// Commande d'affichage des coups jouables
			bouton25 = uicontrol(interfaceJeu, "style", "pushbutton");
			bouton25.Tag = JEU.BOUTONS.Nom25;
			bouton25.Units = "normalized";
			bouton25.Position = JEU.BOUTONS.Position25;
			bouton25.FontSize = JEU.BOUTONS.TaillePolice;
			bouton25.String = "Suggèrer";
			bouton25.BackgroundColor = JEU.BOUTONS.CouleurRVB;
			bouton25.Callback = "controlerAffichageAide()";
			bouton25.Relief = "raised";
			bouton25.Visible = "off";
		//
		// Commande de décimation (aléatoire si un joueur humain, sélective sinon)
			bouton35 = uicontrol(interfaceJeu, "style", "pushbutton");
			bouton35.Tag = JEU.BOUTONS.Nom35;
			bouton35.Units = "normalized";
			bouton35.Position = JEU.BOUTONS.Position35;
			bouton35.FontSize = JEU.BOUTONS.TaillePolice;
			bouton35.String = "Décimer";
			bouton35.BackgroundColor = JEU.BOUTONS.CouleurRVB;
			bouton35.Callback = "controlerDecimationPions()";
			bouton35.Relief = "raised";
			bouton35.Visible = "off";
		//
		// Commande d'interruption de la partie
			bouton45 = uicontrol(interfaceJeu, "style", "pushbutton");
			bouton45.Tag = JEU.BOUTONS.Nom45;
			bouton45.Units = "normalized";
			bouton45.Position = JEU.BOUTONS.Position45;
			bouton45.FontSize = JEU.BOUTONS.TaillePolice;
			bouton45.String = "Arrêter partie";
			bouton45.BackgroundColor = JEU.BOUTONS.CouleurRVB;
			bouton45.Callback = "arreterPartie()";
			bouton45.Relief = "raised";
			bouton45.Visible = "off";
		//
		// Commande de sortie du jeu
			bouton55 = uicontrol(interfaceJeu, "style", "pushbutton");
			bouton55.Tag = JEU.BOUTONS.Nom55;
			bouton55.Units = "normalized";
			bouton55.Position = JEU.BOUTONS.Position55;
			bouton55.FontSize = JEU.BOUTONS.TaillePolice;
			bouton55.String = "Sortir";
			bouton55.BackgroundColor = JEU.BOUTONS.CouleurRVB;
			bouton55.Callback = "sortir()";
			bouton55.Relief = "raised";
			bouton55.Visible = "on";
		//
	case "GrilleSélectionnée" then
		for code = 1:JEU.Partie.NombreJoueurs
			set(get(JEU.MENUS.Nom13Choix(code, 1)), "Visible", "on")
		end
		for code = (JEU.Partie.NombreJoueurs + 1):JEU.JOUEURS_NOMBRE
			set(get(JEU.MENUS.Nom13Choix(code, 1)), "Visible", "off")
		end
	case "PartieRéinitialisée" then
		set(get(JEU.MENUS.Nom11),	"Visible",	"on")
		set(get(JEU.MENUS.Nom12),	"Visible",	"on")
		set(get(JEU.MENUS.Nom13),	"Visible",	"on")
		
		set(get(JEU.BOUTONS.Nom15),	"String",	"Jouer",	"Relief",	"raised",	"Enable",	"on")
		set(get(JEU.BOUTONS.Nom25),	"Visible",	"off")
		set(get(JEU.BOUTONS.Nom35),	"Visible",	"off")
		set(get(JEU.BOUTONS.Nom45),	"Visible",	"off")
		set(get(JEU.BOUTONS.Nom55),	"Visible",	"on")
	case "PartieEnCours" then
		set(get(JEU.MENUS.Nom11),	"Visible",	"off")
		set(get(JEU.MENUS.Nom12),	"Visible",	"off")
		set(get(JEU.MENUS.Nom13),	"Visible",	"off")
		
		set(get(JEU.BOUTONS.Nom15),	"Relief",	"flat",		"Enable",	"off")
		set(get(JEU.BOUTONS.Nom25),	"Visible",	"on")
		set(get(JEU.BOUTONS.Nom35),	"Visible",	"on")
		set(get(JEU.BOUTONS.Nom45),	"Visible",	"on")
		set(get(JEU.BOUTONS.Nom55),	"Visible",	"off")
	case "PartieTerminée" then
		set(get(JEU.MENUS.Nom11),	"Visible",	"on")
		set(get(JEU.MENUS.Nom12),	"Visible",	"on")
		set(get(JEU.MENUS.Nom13),	"Visible",	"on")
		
		set(get(JEU.BOUTONS.Nom15),	"String",	"Effacer",	"Relief",	"raised",	"Enable",	"on")
		set(get(JEU.BOUTONS.Nom25),	"Visible",	"off")
		set(get(JEU.BOUTONS.Nom35),	"Visible",	"off")
		set(get(JEU.BOUTONS.Nom45),	"Visible",	"off")
		set(get(JEU.BOUTONS.Nom55),	"Visible",	"on")
	case "CaseJouables" then
		set(get(JEU.BOUTONS.Nom25),	"Relief",	"flat")
	case "CaseJouablesMasquées" then
		set(get(JEU.BOUTONS.Nom25),	"Relief",	"raised")
	case "Décimation" then
		set(get(JEU.BOUTONS.Nom35),	"Enable",	"off",		"Relief",	"flat")
	case "DécimationTerminée" then
		set(get(JEU.BOUTONS.Nom35),	"Enable",	"on",		"Relief",	"raised")
	end
	
	drawnow()
endfunction
function voirDamier(Action, varargin)
	global JEU
	
	select Action
	case "Création" then
		Taille = varargin(1)
		
		damier = newaxes(get(JEU.INTERFACE.Nom));
		damier.tag = "Damier";
		
		damier.axes_bounds = JEU.DAMIER.Position;
		damier.margins = JEU.DAMIER.Marges;
		
		damier.axes_visible = "off";
		damier.x_location = "top";
		damier.y_location = "left";
		damier.box = "off";
		damier.isoview = "on";
		damier.data_bounds = [0, 0; Taille, Taille];
	case "Initialisation" then
		Taille = varargin(1)
		
		for i = 1:Taille
			for j = 1:Taille
				JEU.Cases(i, j) = "CaseL" + string(i) + "C" + string(j);	
				xfpoly(i - 1 + JEU.CASE.X, j - 1 + JEU.CASE.Y, JEU.CASE.CouleurCode)
				set(gce(), "Tag", JEU.Cases(i, j))
				
				JEU.Cadres(i, j) = "CadreL" + string(i) + "C" + string(j);	
				xpoly(i - 1 + JEU.CASE.X, j - 1 + JEU.CASE.Y, "lines")
				set(gce(), "Tag", JEU.Cadres(i, j))	
				
				JEU.Pions(i, j) = "PionL" + string(i) + "C" + string(j);
				xfpoly(i - 1, j - 1, JEU.CASE.CouleurCode)
				set(gce(), "Tag", JEU.Pions(i, j))	
			end
		end
	case "Destruction" then
		Taille = varargin(1)
		
		objet = get("Damier")
		delete(objet.children)
		objet.data_bounds = [0, 0; Taille, Taille];			// Actualisation des dimensions du damier
		
		JEU.Cases = "";
		JEU.Cadres = "";
		JEU.Pions = "";	
	case "Pions" then
		Grille = varargin(1)
		
		for i = 1:JEU.Partie.Taille
			for j = 1:JEU.Partie.Taille
				if (Grille(i, j) == 0)
					set(get(JEU.Pions(i, j)), "Data", [i - 1, j - 1], "Background", - JEU.CASE.CouleurCode)
				end
				if (Grille(i, j) ~= 0)
					set(get(JEU.Pions(i, j)),											...
						"Data",					[i - 1 + JEU.JOUEURS(Grille(i, j)).X,	...
												 j - 1 + JEU.JOUEURS(Grille(i, j)).Y],	...
						"Background",			JEU.JOUEURS(Grille(i, j)).CouleurCode);
				end
			end
		end
	case "CasesSélectionVoisinage" then
		Voisinage = varargin(1)
		CodeCouleur = varargin(2)
		
		for i = 1:size(Voisinage, 2)
			set(get(JEU.Cases(Voisinage(1, i))), "Background", CodeCouleur)
		end
	case "CasesSélectionRectangle" then
		Rectangle = varargin(1)
		CodeCouleur = varargin(2)
		
		for i = Rectangle(1, 1):Rectangle(2, 1)
			for j = Rectangle(1, 2):Rectangle(2, 2)
				set(get(JEU.Cases(i, j)), "Background", CodeCouleur)
			end
		end
	case "CasesProbabilités" then
		Probabilites = varargin(1)
		ProbabilitesMaximum = max(Probabilites)
		CodeCouleur = varargin(2)
		
		for i = 1:JEU.Partie.Taille
			for j = 1:JEU.Partie.Taille
				if (Grille(i, j) == 0)
					X = [0, 1, 1, 0]';
					if (ProbabilitesMaximum == 0)
						Y = [0, 0, 0, 0]';
					else
						Y = [0, 0, 1, 1]'*Probabilites(i, j)/ProbabilitesMaximum;
					end
					set(get(JEU.Pions(i, j)),							...
						"Data",					[i - 1 + X, j - 1 + Y],	...
						"BackGround",			CodeCouleur				);
				end
			end
		end
	case "CasesEffacées" then
		for i = 1:JEU.Partie.Taille
			for j = 1:JEU.Partie.Taille
				set(get(JEU.Cases(i, j)), "Background", JEU.CASE.CouleurCode)
			end
		end
	end
	
	drawnow()
endfunction
function voirProbabilites(Grille, Code)
	if (Code ~= 0)
		[NombreCases, NombreCasesVides, Probabilites] = calculerProbabilites(Grille, Code, JEU.Partie.Voisinages);
		
		voirDamier("CasesProbabilités", Probabilites, JEU.JOUEURS(Code).CouleurCode)
	end
endfunction
function voirBandeau(Action, Grille, varargin)
	global JEU
	
	if (Action ~= "Création")&(Action ~= "Initialisation")
		ligne1 = string(JEU.Partie.Taille) + " x " + string(JEU.Partie.Taille) + " cases | ";
		ligne1 = ligne1 + string(JEU.Partie.NombreJoueurs) + " joueurs | ";
		if (JEU.Partie.CodeHumain == 0)
			ligne1 = ligne1 + "Mode automatique";
		else
			ligne1 = ligne1 + "Humain joue " + JEU.JOUEURS(JEU.Partie.CodeHumain).Nom;
		end
		
		ligne2 = "";
		[Effectifs, Codes] = calculerEffectifs(Grille)
		for code = 1:JEU.Partie.NombreJoueurs
			if (Effectifs(code, 1) ~= 0)
				Nom = part(JEU.JOUEURS(Codes(code, 1)).Nom, 1:3);
				
				ligne2 = ligne2 + Nom + " (" + string(Effectifs(code, 1)) + ") ";
			end
		end
	end
	
	select Action
	case "Création" then
		bandeau = uicontrol(get(JEU.INTERFACE.Nom), "Style", "text");
		bandeau.Tag = JEU.BANDEAU.Nom;
		bandeau.Position = JEU.BANDEAU.Position;
		bandeau.FontSize = JEU.BANDEAU.TaillePolice;
		bandeau.FontWeight = "bold";
		bandeau.HorizontalAlignment = "left";
		bandeau.String = "";
		bandeau.BackgroundColor = JEU.BANDEAU.CouleurRVB;
	case "Initialisation" then
		ligne1 = "Taille de 8 à 20 | 2 à 4 joueurs | 1 joueur humain maximum";
		ligne2 = "";
		ligne3 = "";
	case "Sélection" then
		ligne3 = "Sélectionnez grille | taille | joueur humain";
	case "CoupPossible" then
		Code = varargin(1);
		Coup = varargin(2);
		
		ligne3 = JEU.JOUEURS(Code).Nom;
		ligne3 = ligne3 + " joue en case (";
		ligne3 = ligne3 + string(Coup(1, 1)) + ", " + string(Coup(1, 2)) + ")";
	case "CoupImpossible" then
		ligne3 = "La case (" + string(l) + ", " + string(c) + ") est déjà remplie";
	case "Décimation" then
		Rectangle = varargin(1);
		
		ligne3 = "Eradication dans le rectangle [";
		ligne3 = ligne3 + string(Rectangle(1, 1)) + ", " + string(Rectangle(1, 2)) + "; ";
		ligne3 = ligne3 + string(Rectangle(2, 1)) + ", " + string(Rectangle(2, 2)) + "]";
	case "PartieInterrompue" then
		ligne3 = "Interruption de la partie";
	case "PartieBloquée" then
		ligne3 = "Partie bloquée : aucune direction gagnable";
	case "PartieVictoire" then
		NomVainqueur = JEU.JOUEURS(varargin(1)).Nom;
		CodeDirection = varargin(2);
		
		if (CodeDirection >= 1)&(CodeDirection <= JEU.Partie.Taille)
			NomDirection = "ligne";
			NomPreposition = "à";
			NomIndice = " " + string(CodeDirection);
		end
		if (CodeDirection > JEU.Partie.Taille)&(CodeDirection <= 2*JEU.Partie.Taille)
			NomDirection = "colonne";
			NomPreposition = "à";
			NomIndice = " " + string(CodeDirection - JEU.Partie.Taille);
		end
		if (CodeDirection == 2*JEU.Partie.Taille + 1)
			NomDirection = "seconde diagonale";
			NomPreposition = "sur";
			NomIndice = "";
		end
		if (CodeDirection == 2*JEU.Partie.Taille + 2)
			NomDirection = "première diagonale";
			NomPreposition = "sur";
			NomIndice = "";
		end
		ligne3 = "Joueur " + NomVainqueur + " vainqueur " + NomPreposition + " la " + NomDirection + NomIndice;
	case "MessageFinPartie" then
		if (JEU.Partie.CodeVainqueur == 0)
			message = "Pas de vainqueur !"
		else
			select JEU.JOUEURS(JEU.Partie.CodeVainqueur).Algorithme
			case 1 then message = "Bravo ! L''Homme a vaincu la Machine !";
			case 2 then message = "Le hasard mène le monde ...";
			case 3 then message = "Votre fin est inéluctable, faibles créatures organiques";
			end
		end
		messagebox(message)	
	else
		ligne1 = "Erreur d''argument d''entrée :";
		ligne2 = "action " + Action;
		ligne3 = "non traitée par la fonction voirBandeau()";
	end
	
	if (Action ~= "Création")
		//mprintf(ligne1 + "\n" + ligne2 + "\n" + ligne3 + "\n\n")
		set(get(JEU.BANDEAU.Nom), "String", "$\textbf{" + ligne1 + "}\\ \textbf{" + ligne2 + "}\\ \textbf{" + ligne3 + "}$")
	end
	
	drawnow()
endfunction

////////////////////////////////////////////////////////////////////////////////
//
//	FONCTIONS CONTROLEURS
  //
  //	Menu	Sélection du nombre de joueurs
  //	Menu	Sélection de la taille de la grille
  //	Menu	Sélection du joueur humain
  //	
  //	Bouton	Nouvelle partie
  //	Bouton	Affichage des probabilités
  //	Bouton	Elimination de pions pour prolonger la partie
  //	Bouton	Arrêt de la partie en cours
  //	Bouton	Sortie du jeu
//
////////////////////////////////////////////////////////////////////////////////

function selectionnerNombre(NombreJoueurs)
	global JEU
	
	JEU.Partie.NombreJoueurs = NombreJoueurs;
	
	for code = 1:JEU.Partie.NombreJoueurs
		JEU.JOUEURS(code).Etat = JEU.ETAT.Actif;
		if (code ~= JEU.Partie.CodeHumain)
			JEU.JOUEURS(code).Algorithme = JEU.ALGORITHME.Robot;
		end
	end
	for code = (JEU.Partie.NombreJoueurs + 1):JEU.JOUEURS_NOMBRE
		JEU.JOUEURS(code).Etat = JEU.ETAT.Inactif;
		JEU.JOUEURS(code).Algorithme = JEU.ALGORITHME.Robot;
	end
	
	voirInterface("GrilleSélectionnée")
	voirDamier("Pions", JEU.Partie.GrilleDebut)
	voirBandeau("Sélection", JEU.Partie.GrilleDebut)
endfunction
function selectionnerTaille(Taille)
	global JEU
	
	JEU.Partie.Taille = Taille;
	JEU.Partie.GrilleDebut = zeros(JEU.Partie.Taille, JEU.Partie.Taille);
	JEU.Partie.NombreDirections = 2*JEU.Partie.Taille + 2;
	JEU.Partie.NombreVoisinages = JEU.Partie.Taille - JEU.Partie.Renju + 1;
	
	voirDamier("Destruction", JEU.Partie.Taille);
	voirDamier("Initialisation", JEU.Partie.Taille);
	voirDamier("Pions", JEU.Partie.GrilleDebut);
	voirBandeau("Sélection", JEU.Partie.GrilleDebut)
endfunction
function selectionnerHumain(CodeHumain)
	global JEU
	
	JEU.Partie.CodeHumain = CodeHumain;
	
	for Code = 1:JEU.Partie.NombreJoueurs
		JEU.JOUEURS(Code).Algorithme = JEU.ALGORITHME.Robot1;
	end
	if (CodeHumain ~= 0)
		JEU.JOUEURS(CodeHumain).Algorithme = JEU.ALGORITHME.Humain;
	end
	
	voirDamier("Pions", JEU.Partie.GrilleDebut)
	voirBandeau("Sélection", JEU.Partie.GrilleDebut)
endfunction

function controlerPartie()
	global JEU
	
	select JEU.Partie.Etat
	case JEU.ETAT_PARTIE.REINITIALISABLE then					// Effacement de la partie précédente
		JEU.Partie.GrilleDebut = zeros(JEU.Partie.Taille, JEU.Partie.Taille);
		
		voirDamier("CasesEffacées")
		voirDamier("Pions", JEU.Partie.GrilleDebut)
		voirInterface("PartieRéinitialisée")
		
		JEU.Partie.Etat = JEU.ETAT_PARTIE.ACTIVABLE;		
	case JEU.ETAT_PARTIE.ACTIVABLE then							// Lancement d'une nouvelle partie
		JEU.Partie.GrilleDebut = zeros(JEU.Partie.Taille, JEU.Partie.Taille);
		
		voirDamier("Pions", JEU.Partie.GrilleDebut)
		voirInterface("PartieEnCours")
		
		JEU.Partie.GrilleFin = jouerPartie(JEU.Partie.GrilleDebut)
		
		voirInterface("PartieTerminée")							// Fin de la nouvelle la partie
		
		JEU.Partie.Etat = JEU.ETAT_PARTIE.REINITIALISABLE;
	end
endfunction
function controlerAffichageAide()
	global JEU
	
	select JEU.Partie.AffichageAide
	case 0 then									// Pas d'affichage = > Affichage pour le joueur humain
		JEU.Partie.AffichageAide = 1;
		
		if (JEU.Partie.CodeHumain == 0)
			controlerAffichageAide()
		end
		
		voirInterface("CasesJouables")
	case 1 then									// Affichage pour le joueur humain => Affichage pour tous les joueurs
		JEU.Partie.AffichageAide = 2;
		
		voirInterface("CasesJouables")
	case 2 then									// Affichage pour tous les joueurs => Pas d'affichage
		JEU.Partie.AffichageAide = 0;
		
		voirInterface("CasesJouablesMasquées")
	end
endfunction
function controlerDecimationPions()
	global JEU
	
	select JEU.Partie.Decimation
	case 0 then									// Sélection des pions à décimer
		voirInterface("Décimation")
		
		if (JEU.Partie.CodeHumain == 0)
			[Rectangle, SelectionEffectuee] = selectionnerRectangle("Humain")
		else
			[Rectangle, SelectionEffectuee] = selectionnerRectangle("Aléatoire")
		end
		
		if (SelectionEffectuee)
			JEU.Selection = Rectangle;
			
			voirDamier("CasesEffacées")
			voirDamier("CasesSélectionRectangle", JEU.Selection, color("red"))
			
			JEU.Partie.Decimation = 1;
		else
			voirDamier("CasesEffacées")
			voirInterface("DécimationTerminée")
		
			JEU.Partie.Decimation = 0;
		end
	case 1 then									// Décimation des pions sélectionnés
		voirInterface("DécimationTerminée")
		
		JEU.Partie.Decimation = 0;
	end
endfunction
function arreterPartie()
	global JEU
	
	JEU.Partie.Etat = JEU.ETAT_PARTIE.INTERROMPUE;
endfunction
function sortir()
	xdel(winsid())
endfunction

////////////////////////////////////////////////////////////////////////////////
//
//	PROGRAMME PRINCIPAL
//
////////////////////////////////////////////////////////////////////////////////

affecterParametres()
voirInterface("Création")

//Essai = 3;
//Essai = 5;
Essai = 9;

select Essai
case 3 then
	selectionnerTaille(3)
	selectionnerNombre(2)
	selectionnerHumain(0)
	JEU.JOUEURS(2).Algorithme = JEU.ALGORITHME.Robot;
case 5 then
	selectionnerTaille(5)
	selectionnerNombre(4)
	selectionnerHumain(0)
	JEU.JOUEURS(2).Algorithme = JEU.ALGORITHME.Robot;
	JEU.JOUEURS(3).Algorithme = JEU.ALGORITHME.Robot;
	JEU.JOUEURS(4).Algorithme = JEU.ALGORITHME.Robot;
case 9 then
	selectionnerTaille(9)
	selectionnerNombre(4)
	selectionnerHumain(0)
	JEU.JOUEURS(2).Algorithme = JEU.ALGORITHME.Robot;
	JEU.JOUEURS(3).Algorithme = JEU.ALGORITHME.Robot;
	JEU.JOUEURS(4).Algorithme = JEU.ALGORITHME.Robot;
case 10 then
	selectionnerTaille(10)
	selectionnerNombre(4)
	selectionnerHumain(0)
end