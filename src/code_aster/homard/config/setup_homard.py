#!/usr/bin/env python
# coding: utf-8
"""
Programme d'installation de HOMARD

Copyright EDF-R&D 2004, 2005, 2011
"""
#
__revision__ = "V2.6"
#
from utilitaires import int_to_str2
from utilitaires import lien
from utilitaires import tue_rep
#
import os
import tempfile
import platform
import shutil
from glob import glob
#
class Installation :
#
  """
  Classe de l'installation de HOMARD.
  """
#
#
#====
# 0. Les défauts
#====
#
# 0.1. ==> Le français par défaut
#
  langue_defaut = "fr"
  logiciel_nom_officiel = "Code_Aster"
#
# 0.2. ==> Les messages en francais
#
  texte_fr = {}
#
  texte_fr["Aide"]                     = ["Cette procédure sert à installer HOMARD.\n"]
  texte_fr["Aide_Fichier"]             = "A_Lire.txt"
#
  texte_fr["config_txt_lire"]          = "Nom du fichier 'config.txt' associé à cette version de " + logiciel_nom_officiel + " ?\n"
  texte_fr["Repertoire_Lire"]          = "Dans quel répertoire doit-on installer HOMARD ?\n"
  texte_fr["Repertoire_Nom"]           = "Nom du répertoire :"
  texte_fr["Repertoire_Absent"]        = "Ce répertoire n'existe pas."
  texte_fr["Repertoire_Creation"]      = "Voulez-vous le créer ? (o/n) \n"
  texte_fr["Repertoire_Interdit"]      = "Ecriture interdite."
  texte_fr["Repertoire_remove"]        = "Erreur a la destruction de ce répertoire."
  texte_fr["Repertoire_mkdir"]         = "A la création de ce répertoire"
  texte_fr["Repertoire_chdir"]         = "Au changement de répertoire"
  texte_fr["Repertoire_Instal_Exec"]   = "... Répertoire d'installation de l'exécutable :"
#
  texte_fr["CONFIG_erreur"]            = "Fichier config.txt : impossible de décoder "
  texte_fr["BIBLI_erreur"]             = "Impossible de trouver les bibliothèques dans config.txt."
#
  texte_fr["Fichier_Nom"]              = "Nom du fichier :"
  texte_fr["Fichier_Absent"]           = "Ce fichier est inconnu.\n"
  texte_fr["Fichier_ar"]               = "Probleme à la constitution de l'archive."
  texte_fr["Fichier_detar"]            = "Probleme à l'extraction de l'archive."
  texte_fr["Fichier_chmod"]            = "Probleme au changement de droits."
  texte_fr["Fichier_remove"]           = "Erreur a la destruction de ce fichier."
#
  texte_fr["Python_Lire"]              = "Nom de l'exécutable python utilisé pour " + logiciel_nom_officiel + " ?\n"
#
  texte_fr["HOMARD_Exec_Inconnu"]      = "L'exécutable HOMARD est inconnu dans "
  texte_fr["HOMARD_Adaptation"]        = "....... Adaptation du maillage numéro "
  texte_fr["HOMARD_Vers"]              = " vers le maillage numéro "
  texte_fr["HOMARD_Erreur"]            = "Erreur à l'exécution de HOMARD."
#
  texte_fr["Cas_Test_Lancement"]       = "\n. Lancement des cas tests"
  texte_fr["Cas_Test_Nom"]             = "\n... Cas test :"
  texte_fr["Cas_Test_Comparaison"]     = "..... Comparaison avec la référence"
  texte_fr["Cas_Test_Iteration"]       = ".. Après l'adaptation du maillage numéro "
  texte_fr["Cas_Test_Bilan_nblg"]      = "Les fichiers de bilan n'ont pas la même longueur."
  texte_fr["Cas_Test_Bilan_lg_ref"]    = ".. Dans la référence :     "
  texte_fr["Cas_Test_Bilan_lg"]        = ".. Dans le calcul courant :"
  texte_fr["Cas_Test_Bilan_diff"]      = "Les fichiers de bilan diffèrent."
  texte_fr["Cas_Test_OK"]              = "..... Cas test passé avec succès."
  texte_fr["Cas_Test_PB"]              = "Problème dans le passage des cas-tests."
#
  texte_fr["Erreur_Numero"]            = ", erreur numéro "
#
  texte_fr["Installation_OK"]          = "\nL'installation est réussie.\n"
  texte_fr["Installation_Pb"]          = "\nL'installation a échoué.\n"
  texte_fr["Installation_En_tete"]     = "\nInstallation de HOMARD version"
  texte_fr["Installation_HOMARD_Exec"] = "\n. Installation de l'exécutable HOMARD"
  texte_fr["Installation_Couplage"]    = "\n. Installation des procédures de couplage " + logiciel_nom_officiel + "-HOMARD"
  texte_fr["Installation_Cas_Test"]    = "\n. Installation des cas tests"
#
  texte_fr["Creation_OK"]              = "\nLa création de l'exécutable est réussie.\n"
  texte_fr["Creation_Pb"]              = "\nLa création de l'exécutable a échoué.\n"
  texte_fr["Creation_En_tete"]         = "\nCréation de l'exécutable HOMARD"
  texte_fr["Creation_HOMARD_Exec"]     = "\n. Création de l'exécutable HOMARD"
  texte_fr["Creation_pb_make"]         = "\nProblème à l'exécution du makefile."
#
# 0.3. ==> Les messages en anglais
#
  texte_en = {}
#
  texte_en["Aide"]                     = ["This setup is used to install HOMARD.\n"]
  texte_en["Aide_Fichier"]             = "Readme.txt"
#
  texte_en["config_txt_lire"]          = "Name of file 'config.txt' connected to this release of " + logiciel_nom_officiel + " release ?\n"
  texte_en["Repertoire_Lire"]          = "What is the directory for HOMARD installation ?\n"
  texte_en["Repertoire_Nom"]           = "Name of the directory :"
  texte_en["Repertoire_Absent"]        = "This directory does not exist."
  texte_en["Repertoire_Creation"]      = "Do you want creation ? (y/n) \n"
  texte_en["Repertoire_Interdit"]      = "No rights for writing."
  texte_en["Repertoire_remove"]        = "Error when removing this directory."
  texte_en["Repertoire_mkdir"]         = "When creating this directory"
  texte_en["Repertoire_chdir"]         = "When changing"
  texte_en["Repertoire_Instal_Exec"]   = "... Directory for exec installation :"
#
  texte_en["CONFIG_erreur"]            = "config.txt file : cannot be found : "
  texte_en["BIBLI_erreur"]             = "Libraries cannot be found in config.txt."
#
  texte_en["Fichier_Nom"]              = "Name of the file :"
  texte_en["Fichier_Absent"]           = "This file does not exist.\n"
  texte_en["Fichier_ar"]               = "Problem while creating archive file."
  texte_en["Fichier_detar"]            = "Problem while extracting from the archive file"
  texte_en["Fichier_remove"]           = "Error when removing this file."
#
  texte_en["Python_Lire"]              = "Name of the python program which is used for  " + logiciel_nom_officiel + " ?\n"
#
  texte_en["HOMARD_Exec_Inconnu"]      = "The HOMARD programm is unknown in "
  texte_en["HOMARD_Adaptation"]        = "....... Adaptation from mesh # "
  texte_en["HOMARD_Vers"]              = " to mesh # "
  texte_en["HOMARD_Erreur"]            = "Error when HOMARD was running."
#
  texte_en["Cas_Test_Lancement"]       = "\n. Test cases execution"
  texte_en["Cas_Test_Nom"]             = "\n... Test case :"
  texte_en["Cas_Test_Comparaison"]     = "..... Comparizon with reference"
  texte_en["Cas_Test_Iteration"]       = ".. After adaptation from mesh # "
  texte_en["Cas_Test_Bilan_nblg"]      = "The lengths of the result files are not the same."
  texte_en["Cas_Test_Bilan_lg_ref"]    = ".. In reference :              "
  texte_en["Cas_Test_Bilan_lg"]        = ".. In the current computation :"
  texte_en["Cas_Test_Bilan_diff"]      = "Result files are not the same."
  texte_en["Cas_Test_OK"]              = "..... Test case passed."
  texte_en["Cas_Test_PB"]              = "Problem in test-case analysis."
#
  texte_en["Erreur_Numero"]            = ", error # "
#
  texte_en["Installation_OK"]          = "\nInstallation passed.\n"
  texte_en["Installation_Pb"]          = "\nInstallation failed.\n"
  texte_en["Installation_En_tete"]     = "\nInstallation of HOMARD release"
  texte_en["Installation_HOMARD_Exec"] = "\n. Install of HOMARD programm"
  texte_en["Installation_Couplage"]    = "\n. Install of coupling " + logiciel_nom_officiel + "-HOMARD programm"
  texte_en["Installation_Cas_Test"]    = "\n. Install of test cases"
#
  texte_en["Creation_OK"]              = "\nCreation of load module passed.\n"
  texte_en["Creation_Pb"]              = "\nCreation of load module failed.\n"
  texte_en["Creation_En_tete"]         = "\nCreation of load module HOMARD"
  texte_en["Creation_HOMARD_Exec"]     = "\n. Creation of load module HOMARD"
  texte_en["Creation_pb_make"]         = "\nProblem while executing makefile."
#
# 0.4. ==> Les messages generaux
#
  mess = {}
  mess["Ligne"] = "\n====================================================================\n"
  mess["Copyright"] = "\nCopyright Electricité de France - R&D - 1996, 1997, 2011\n"
#
# 0.5. Le systeme
#
  system = platform.uname()[0]
  arch = platform.uname()[4]
  rep_loc = system
  if arch in [ "x86_64", "ia_64" ] :
    rep_loc = rep_loc + "64"
#
#
#========================= Debut de la fonction ==================================
#
#
  def __init__ (self, liste_option_init ) :
#
    """
    Le constructeur
    """
#
# 1.1. ==> Les options de base
#
    langue = self.langue_defaut
    if "-en" in liste_option_init :
      langue = "en"
    self.langue = langue
#
    if "-v" in liste_option_init :
      self.option_ar    = "-cf"
      self.option_detar = "-xf"
      self.verbose = 1
    elif "-vmax" in liste_option_init :
      self.option_ar    = "-cvf"
      self.option_detar = "-xvf"
      self.verbose = 1
    else :
      self.option_ar    = "-cf"
      self.option_detar = "-xf"
      self.verbose = 0

    prefix = [opt for opt in liste_option_init if opt.startswith('--prefix=')]
    assert len(prefix) == 1, "option --prefix est requise !"
    self.repinst = prefix[0].split('--prefix=')[1]
#
# 1.2. ==> Les messages
#
    if self.langue == "fr" :
      self.message = self.texte_fr
    else :
      self.message = self.texte_en
    for cle in self.mess.keys() :
      self.message[cle] = self.mess[cle]
#
    self.Rep_Base = os.getcwd()
#
# 1.3. ==> Les informations particulières
#
    self.dict_options = {}
    self.Nom_Transfert = "HOMARD"
    self.Rep_Arch = os.path.join ( self.Rep_Base, self.Nom_Transfert )
#
    self.HOMARD_VERSION = "V11.12"
    self.Rep_Proc_Couplage = "ASTER_HOMARD"
    self.prefixe = "homard"
#
#
#=========================  Fin de la fonction ===================================
#
#========================= Debut de la fonction ==================================
#
#
  def aide (self) :
#
    """
    Afficher les informations d'aide
    """
#
    fic_aide = os.path.join(os.getcwd(), self.message["Aide_Fichier"])
    if os.path.isfile(fic_aide) :
      fic = open (fic_aide, "r" )
      les_lignes = fic.readlines()
      fic.close()
    else :
      les_lignes = self.message["Aide"]
      les_lignes.append(self.message["Copyright"])
    print (self.message["Ligne"])
    for ligne in les_lignes :
      print (ligne[0:-1])
    print (self.message["Ligne"])
#
#
#=========================  Fin de la fonction ===================================
#
#========================= Debut de la fonction ==================================
#
#
  def data(self):
    self.dict_options['REPOUT'], self.Nom_Transfert = os.path.split(self.repinst)
    self.dict_options['PYTHON'] = sys.executable
    return None

  def _data (self) :
#
    """
    Lit les données pour installer HOMARD
    """
#
    message_erreur = None
#
    if self.verbose :
      print (self.message["Installation_En_tete"], self.HOMARD_VERSION)
#
# 1.1. ==> Nom du fichier de configuration de l'installation
#
    print (self.message["Ligne"])
#
    encore = 1
    while encore :
      fic = raw_input(self.message["config_txt_lire"])
      if len(fic) > 0 :
        aux = fic.lstrip()
        fic = aux.rstrip()
        if os.path.isfile(fic) :
          break
        else :
          print (self.message["Fichier_Nom"], fic)
          print (self.message["Fichier_Absent"])
#
    fic_bis = os.path.join(self.Rep_Base, fic)
    if os.path.isfile(fic_bis) :
      fic = fic_bis
#
# 1.2. ==> Décodage du fichier de configuration de l'installation
#
    fichier = open (fic,"r")
    les_lignes = fichier.readlines()
    fichier.close()
#
    liste_options = ["REPOUT", "PYTHON" ]
#
    for ligne in les_lignes :
      l_aux = ligne.split()
      if len(l_aux) > 6 :
###        print (".... l_aux = ", l_aux)
        option = l_aux[0]
        if self.dict_options.has_key(option) :
          saux = self.dict_options[option]
          ideb = 6
        else :
          saux = l_aux[6]
          ideb = 7
        for saux_bis in l_aux[ideb:] :
          saux = saux + " " + saux_bis
        self.dict_options[option] = saux
#
    for option in liste_options :
      if not self.dict_options.has_key(option) :
        message_erreur = self.message["CONFIG_erreur"] + option
        break
      else :
        if self.verbose :
          print (option, ":", self.dict_options[option])
#
    if message_erreur == None :
      print (self.message["Ligne"])
#
###    message_erreur = self.message["Installation_Pb"]
    return message_erreur
#
#
#=========================  Fin de la fonction ===================================
#
#
#========================= Debut de la fonction ==================================
#
#
  def installation (self) :
#
    """
    Installer HOMARD
    """
#
# 1.0. ==> Initialisation
#
    t_aux = tempfile.mkstemp()
    fic_tar = t_aux[1]
#
    repout = os.path.normpath(self.dict_options["REPOUT"])
    self.rep_install_homard = os.path.join(repout, self.Nom_Transfert)
#
    message_erreur = None
    erreur = 0
#
    while not erreur :
#
# 1.1. ==> Transfert de l'exécutable
#          Attention : on ne peut pas procéder par renommage car cela ne fonctionne pas
#                      si les fichiers ne sont pas sur les memes disques. On passe
#                      donc par un fichier d'archive tampon.
#
      print (self.message["Installation_HOMARD_Exec"])
#
      self.homard_exe_loc = "HOMARD_V*.out"
#
# 1.1.1. ==> Le répertoire où sera mis l'exécutable.
#            . S'il n'existe pas, on le crée.
#            . S'il existe, on vérifie que l'on peut y aller et y écrire. On ne le détruit surtout pas,
#              car il peut contenir d'autres versions de HOMARD à conserver.
#
      rep_install_exec = os.path.join(self.rep_install_homard, self.rep_loc)
#
      if self.verbose :
        print (self.message["Repertoire_Instal_Exec"], rep_install_exec)
#
      liste_rep = [self.rep_install_homard, rep_install_exec]
#
      for rep in liste_rep :
        err = [0]
        if not os.path.isdir(rep) :
          try :
            os.mkdir(rep)
          except os.error as err :
            print (self.message["Repertoire_Nom"], rep)
            message_erreur = self.message["Repertoire_mkdir"] + self.message["Erreur_Numero"] + str(err[0]) + " : " + str(err[1])
            break
#
        if not os.access(rep, os.W_OK) or not os.access(rep, os.X_OK) :
          print (self.message["Repertoire_Nom"], rep)
          print (self.message["Repertoire_Interdit"])
          break
#
      if err[0] :
        break
#
# 1.1.2. ==> Archivage du point de départ
#
      if self.verbose :
        print ("... Récupération du point de départ")
#
      rep_recup = os.path.join(self.Rep_Base, self.rep_loc)
      err = [0]
      try :
        os.chdir(rep_recup)
      except os.error as err :
        print (self.message["Repertoire_Nom"], rep_recup)
        message_erreur = self.message["Repertoire_chdir"] + self.message["Erreur_Numero"] + str(err[0]) + " : " + str(err[1])
        break
#
      commande = "tar " + self.option_ar + " " + fic_tar + " " + self.homard_exe_loc
      erreur = os.system (commande)
      if erreur :
        message_erreur  = "... Dans le répertoire " + os.getcwd()
        message_erreur += "\n" + commande
        message_erreur += "\n" + self.message["Fichier_ar"]
        break
#
# 1.1.3. ==> Extraction
#
      if self.verbose :
        print ("... Extraction dans", rep_install_exec)
#
      err = [0]
      try :
        os.chdir(rep_install_exec)
      except os.error as err :
        print (self.message["Repertoire_Nom"], rep_install_exec)
        message_erreur = self.message["Repertoire_chdir"] + self.message["Erreur_Numero"] + str(err[0]) + " : " + str(err[1])
        break
#
      commande = "tar " + self.option_detar + " " + fic_tar
      erreur = os.system (commande)
      if erreur :
        message_erreur = self.message["Fichier_detar"]
        break
#
      lexe = glob(self.homard_exe_loc)
      self.homard_exe = os.path.join(rep_install_exec, lexe[0])
#
# 1.1.4. ==> Droit d'exécution
#
      for homard_exe in lexe:
          err = [0]
          try :
            os.chmod  (homard_exe, 0o755)
          except os.error as err :
            print (self.message["Fichier_Nom"], homard_exe)
            message_erreur = self.message["Fichier_chmod"]
            break
#
# 1.2. ==> Transfert des procédures de couplage avec le logiciel
#          Attention : on ne peut pas procéder par renommage car cela ne fonctionne pas
#                      si les répertoires ne sont pas sur les memes disques. On passe
#                      donc par un fichier d'archive tampon.
#
#
      print (self.message["Installation_Couplage"])
#
# 1.2.1. ==> Le répertoire où seront mises les procédures de couplage
#            . Si le répertoire existe déjà, on le supprime.
#
      if self.verbose :
        print ("... Le répertoire où seront mises les procédures de couplage")
#
      Rep_Install_Couplage = os.path.join(self.rep_install_homard, self.Rep_Proc_Couplage)
#
      if os.path.isdir(Rep_Install_Couplage) :
        erreur = tue_rep ( Rep_Install_Couplage )
      if erreur :
        print (self.message["Repertoire_Nom"], Rep_Install_Couplage)
        message_erreur = self.message["Repertoire_remove"]
        break
#
# 1.2.2. ==> Archivage du point de départ
#
      if self.verbose :
        print ("... Récupération du point de départ")
#
      err = [0]
      try :
        os.chdir(self.Rep_Base)
      except os.error as err :
        print (self.message["Repertoire_Nom"], self.Rep_Base)
        message_erreur = self.message["Repertoire_chdir"] + self.message["Erreur_Numero"] + str(err[0]) + " : " + str(err[1])
        break
#
      commande = "tar " + self.option_ar + " " + fic_tar + " " + self.Rep_Proc_Couplage
      erreur = os.system (commande)
      if erreur :
        message_erreur = self.message["Fichier_ar"]
        break
#
# 1.2.3. ==> Extraction
#
      if self.verbose :
        print ("... Extraction dans", self.rep_install_homard)
#
      err = [0]
      try :
        os.chdir(self.rep_install_homard)
      except os.error as err :
        print (self.message["Repertoire_Nom"], self.rep_install_homard)
        message_erreur = self.message["Repertoire_chdir"] + self.message["Erreur_Numero"] + str(err[0]) + " : " + str(err[1])
        break
#
      commande = "tar " + self.option_detar + " " + fic_tar
      erreur = os.system (commande)
      if erreur :
        message_erreur = self.message["Fichier_detar"]
        break
#
# 1.2.4. ==> Mise à jour du script de couplage avec le logiciel
#
      if self.verbose :
        print ("... Mise à jour du script de couplage avec", self.logiciel_nom_officiel)
#
# 1.2.4.1. ==> Lecture de la base
#
      lance_homard_base = os.path.join ( self.Rep_Base, self.prefixe + "_base" )
      if not os.path.isfile(lance_homard_base) :
        print (self.message["Fichier_Nom"], lance_homard_base)
        message_erreur = self.message["Fichier_Absent"]
        break
#
      fic = open (lance_homard_base, 'r' )
      lignes = fic.readlines()
      fic.close()
#
# 1.2.4.2. ==> On écrit toutes les lignes à l'identique, en ajoutant la première où on doit mettre le bon python
#
      lance_homard = os.path.join ( self.rep_install_homard, self.Rep_Proc_Couplage, self.prefixe + ".py")
      if self.verbose :
        print ("    fichier :", lance_homard)
#
      err = [0]
      if os.path.isfile(lance_homard) :
        try :
          os.remove(lance_homard)
        except os.error as err :
          print (self.message["Fichier_Nom"], lance_homard)
          message_erreur = self.message["Fichier_remove"]
      if err[0] :
        break
#
      fic = open (lance_homard, "w" )
#
      ligne = "#!" + self.dict_options["PYTHON"] + "\n"
      fic.write(ligne)
      for ligne in lignes[1:] :
        fic.write(ligne)
#
      fic.close()
#
      os.chmod(lance_homard, 0o755)
#
# 1.2.5. ==> Lien avec la procédure de lancement
#
      if self.verbose :
        print ("... Lien avec la procédure de lancement")
#
      fic_arrivee = os.path.join(self.repinst, "homard")
      lance_homard_rel = os.path.join (self.Rep_Proc_Couplage, self.prefixe)
      erreur = lien (lance_homard_rel, fic_arrivee, "non")
#
# 1.4. ==> C'est fini
#
      break
#
#    print (fic_tar)
    if os.path.isfile(fic_tar) :
      os.chmod(fic_tar, 0o644)
      err = [0]
      try :
        os.remove(fic_tar)
      except os.error as err :
        print (self.message["Fichier_Nom"], fic_tar)
        message_erreur = self.message["Fichier_remove"]
#
    os.chdir(self.Rep_Base)
#
    if message_erreur == None :
      message_bis = self.message["Installation_OK"]
    else :
      message_bis = self.message["Installation_Pb"]
    return message_erreur, message_bis
#
#
#=========================  Fin de la fonction ===================================
#
#========================= Debut de la fonction ==================================
#
#
  def cas_test (self) :
#
    """
    Lancement des cas_tests de vérification de l'installation HOMARD
    """
    if not self.rep_loc.endswith('64'):
        print ("skip testcases installation on 32 bits platforms")
        return None, self.message["Installation_OK"]

#
# 1.0. ==> Initialisation
#
    t_aux = tempfile.mkstemp()
    fic_tar = t_aux[1]
#
    message_erreur = None
    erreur = 0
#
    while not erreur :
#
      print (self.message["Installation_Cas_Test"])
#
# 1.1. ==> Transfert du répertoire des cas_tests
#
      if self.verbose :
        print ("... Le répertoire où seront mis les cas-tests")
#
      Rep_Cas_Test_depart = os.path.join(self.Rep_Base, self.rep_loc, "CAS_TESTS")
      Rep_Cas_Test = os.path.join(self.rep_install_homard, "CAS_TESTS", self.rep_loc, self.HOMARD_VERSION)
#
# 1.1.1. ==> Création éventuelle du répertoire général des cas-tests
#
      rep = os.path.join(self.rep_install_homard, "CAS_TESTS")
      err = [0]
      if not os.path.isdir(rep) :
        try :
          os.mkdir(rep)
        except os.error as err :
          print (self.message["Repertoire_Nom"], rep)
          message_erreur = self.message["Repertoire_mkdir"] + self.message["Erreur_Numero"] + str(err[0]) + " : " + str(err[1])
      if err[0] :
        break
#
# 1.1.2. ==> Création éventuelle du répertoire spécifique des cas-tests
#
      rep = os.path.join(rep, self.rep_loc)
      err = [0]
      if not os.path.isdir(rep) :
        try :
          os.mkdir(rep)
        except os.error as err :
          print (self.message["Repertoire_Nom"], rep)
          message_erreur = self.message["Repertoire_mkdir"] + self.message["Erreur_Numero"] + str(err[0]) + " : " + str(err[1])
      if err[0] :
        break
#
# 1.1.3. ==> Si le répertoire des cas-tests de la version à installer existe déjà, on le supprime, puis on le cree
#
      erreur = 0
      if os.path.isdir(Rep_Cas_Test) :
        erreur = tue_rep ( Rep_Cas_Test )
      if erreur :
        print (self.message["Repertoire_Nom"], Rep_Cas_Test)
        message_erreur = self.message["Repertoire_remove"]
        break
#
      err = [0]
      try :
        os.mkdir(Rep_Cas_Test)
      except os.error as err :
        print (self.message["Repertoire_Nom"], Rep_Cas_Test)
        message_erreur = self.message["Repertoire_mkdir"] + self.message["Erreur_Numero"] + str(err[0]) + " : " + str(err[1])
        break
#
# 1.2. ==> Transfert
#          Attention : on ne peut pas procéder par renommage car cela ne fonctionne pas
#                      si les répertoires ne sont pas sur les memes disques. On passe
#                      donc par un fichier d'archive tampon.
#
      if self.verbose :
        print ("... Transfert")
#
# 1.2.1. ==> Archivage du point de départ
#
      if self.verbose :
        print ("... Récupération du point de départ")
#
      err = [0]
      try :
        os.chdir(Rep_Cas_Test_depart)
      except os.error as err :
        print (self.message["Repertoire_Nom"], Rep_Cas_Test_depart)
        message_erreur = self.message["Repertoire_chdir"] + self.message["Erreur_Numero"] + str(err[0]) + " : " + str(err[1])
        break
#
      commande = "tar " + self.option_ar + " " + fic_tar + " *"
      erreur = os.system (commande)
      if erreur :
        message_erreur = self.message["Fichier_ar"]
        break
#
# 1.2.2. ==> Extraction
#
      if self.verbose :
        print ("... Extraction dans", Rep_Cas_Test)
#
      err = [0]
      try :
        os.chdir(Rep_Cas_Test)
      except os.error as err :
        print (self.message["Repertoire_Nom"], Rep_Cas_Test)
        message_erreur = self.message["Repertoire_chdir"] + self.message["Erreur_Numero"] + str(err[0]) + " : " + str(err[1])
        break
#
      commande = "tar " + self.option_detar + " " + fic_tar
      erreur = os.system (commande)
      if erreur :
        message_erreur = self.message["Fichier_detar"]
        break
#
# 1.3. ==> Lancement des tests
#
      print (self.message["Cas_Test_Lancement"])
#
      liste_cas = os.listdir ( os.getcwd() )
      message_erreur_cas = {}
#
      for cas in liste_cas :
#
        message_erreur_cas[cas] = None
#
# 1.3.1. ==> Passage dans le répertoire de calcul
#
        print (self.message["Cas_Test_Nom"], cas)
        Rep_Cas_Test_Resultat = os.path.join(Rep_Cas_Test, cas, "resultats")
        err = [0]
        try :
          os.makedirs(Rep_Cas_Test_Resultat)
          os.chdir(Rep_Cas_Test_Resultat)
        except os.error as err :
          message_erreur_cas[cas]  = self.message["Repertoire_Nom"] + Rep_Cas_Test_Resultat
          message_erreur_cas[cas] += self.message["Repertoire_chdir"] + self.message["Erreur_Numero"] + str(err[0]) + " : " + str(err[1])
          break
        Rep_Cas_Test_Resultat_Ref = os.path.join(Rep_Cas_Test, cas,"resultats_ref")
        if self.verbose :
          print ("... Reference dans", Rep_Cas_Test_Resultat_Ref)
          print ("... Calcul dans   ", Rep_Cas_Test_Resultat)
#
# 1.3.2. ==> Initialisations
#
        fic_conf = os.path.join(Rep_Cas_Test_Resultat, "HOMARD.Configuration")
#
# 1.3.3. ==> Boucle sur toutes les adaptations possibles
#
        nbiterp1 = 0
        while message_erreur_cas[cas] == None :
#
          nbiter = nbiterp1
          nbiterp1 = nbiter + 1
#
# 1.3.3.1. ==> Création du fichier de configuration
#
          aux_nbiter = int_to_str2(nbiter)
          aux_nbiterp1 = int_to_str2(nbiterp1)
          suffixe = aux_nbiter + ".vers." + aux_nbiterp1
          fic_conf_spec = os.path.join(Rep_Cas_Test_Resultat_Ref, "HOMARD.Configuration." + suffixe)
          if not os.path.isfile(fic_conf_spec) :
            break
#
          shutil.copyfile(fic_conf_spec, fic_conf)
#
# 1.3.3.2. ==> Lancement de l'adaptation de nbiter vers nbiter+1
#
          print (self.message["HOMARD_Adaptation"] + aux_nbiter + self.message["HOMARD_Vers"] + aux_nbiterp1)
          erreur = os.system (self.homard_exe)
          if erreur :
            message_erreur_cas[cas] = self.message["HOMARD_Erreur"]
            break
#
# 1.3.4. ==> Comparaisons :
#            Attention, il faut les faire seulement quand tout est fini, sinon
#                       il y a des incohérences de messages qui ne sont pas des erreurs
#
        if message_erreur_cas[cas] == None :
#
          if self.verbose :
            print (self.message["Cas_Test_Comparaison"])
#
          nbiter_max = nbiter
          for nbiter in range(nbiter_max) :
#
            nbiterp1 = nbiter + 1
            aux_nbiter = int_to_str2(nbiter)
            aux_nbiterp1 = int_to_str2(nbiterp1)
            suffixe = aux_nbiterp1 + ".bilan"
            nberror = 0
#
            for pref in ( "modi.00.bilan", "apad" + "." + suffixe ) :
#
              ok_1 = 1
              ok_2 = 1
#
              Fic_Bilan_ref = os.path.join(Rep_Cas_Test_Resultat    , pref)
              if not os.path.isfile(Fic_Bilan_ref) :
                ok_1 = 0
#
              Fic_Bilan     = os.path.join(Rep_Cas_Test_Resultat_Ref, pref)
              if not os.path.isfile(Fic_Bilan) :
                ok_2 = 0
#
              if ( ok_1 and ok_2 ) :
                break
#
            if ( not ok_1 or not ok_2 ) :
              message_erreur_cas[cas]  = self.message["Fichier_Nom"] + Fic_Bilan + "\n"
              message_erreur_cas[cas] += self.message["Fichier_Nom"] + Fic_Bilan_ref + "\n"
              message_erreur_cas[cas] += self.message["Fichier_Absent"]
              break
#
            fic = open (Fic_Bilan_ref, "r" )
            Bilan_Ref = fic.readlines()
            fic.close()
#
            fic = open (Fic_Bilan, "r" )
            Bilan = fic.readlines()
            fic.close()
#
            nbligne = len(Bilan)
            if ( nbligne != len(Bilan_Ref) ) :
              message_erreur_cas[cas]  = self.message["Cas_Test_Iteration"] + aux_nbiter
              message_erreur_cas[cas] += self.message["HOMARD_Vers"] + aux_nbiterp1 + " :\n"
              message_erreur_cas[cas] += self.message["Cas_Test_Bilan_nblg"]
              break
#
            for num_ligne in range(nbligne) :
              if Bilan[num_ligne] != Bilan_Ref[num_ligne] :
                if (     Bilan[num_ligne][5:9] == "Date" and     Bilan[num_ligne][13:21] == "creation" and
                     Bilan_Ref[num_ligne][5:9] == "Date" and Bilan_Ref[num_ligne][13:21] == "creation" ) :
                  pass
                else :
                  if nberror == 0 :
                    nberror = 1
                    print (self.message["Cas_Test_Iteration"] + aux_nbiter + self.message["HOMARD_Vers"] + aux_nbiterp1 + " :")
                  print (self.message["Cas_Test_Bilan_lg_ref"], Bilan_Ref[num_ligne][0:-1])
                  print (self.message["Cas_Test_Bilan_lg"],     Bilan[num_ligne][0:-1])
                  message_erreur_cas[cas] = self.message["Cas_Test_Bilan_diff"]
#
# 1.3.4. ==> Bilan
#
        if message_erreur_cas[cas] == None :
          print (self.message["Cas_Test_OK"])
        else :
          print (message_erreur_cas[cas])
#
# 1.4. ==> Bilan
#
      for cas in liste_cas :
#
        if message_erreur_cas[cas] != None :
          message_erreur = self.message["Cas_Test_PB"]
          break
#
      if message_erreur == None :
        print (self.message["Cas_Test_OK"])
#
# 1.5. ==> C'est fini
#
      break
#
    if os.path.isfile(fic_tar) :
      os.chmod(fic_tar, 0o644)
      err = [0]
      try :
        os.remove(fic_tar)
      except os.error as err :
        print (self.message["Fichier_Nom"], fic_tar)
        message_erreur = self.message["Fichier_remove"]
#
    os.chdir(self.Rep_Base)
#
    if message_erreur == None :
      message_bis = self.message["Installation_OK"]
    else :
      message_bis = self.message["Installation_Pb"]
    return message_erreur, message_bis
#
#
#=========================  Fin de la fonction ===================================
#
#=====================================================================
#
#
if __name__ == "__main__" :
#
  import sys
#
# 1. ==> Récupération des arguments
#
  liste_option_main = sys.argv[1:]
#
  liste_aide = [ "-h", "-help", "-aide" ]
  aide = 0
  for mot_cle in liste_aide :
    if mot_cle in liste_option_main :
      aide = 1
#
# 2. ==> Création de la classe
#
  install = Installation(liste_option_main)
#
# 3. ==> Fait-on une demande d'aide ? ou est-ce le traitement standard ?
#
  message_erreur_main = None
  message_bis_main = " "
#
# 3.0. ==> Aide
#
  if aide :
    install.aide()
  else :
#
# 3.1. ==> Les données
#
    message_erreur_main = install.data()
#
# 3.3. ==> Installation
#
    if message_erreur_main == None :
      message_erreur_main, message_bis_main = install.installation()
#
# 3.3. ==> Installation et passage des cas-tests
#
# skip testcases
# skip testcases
    if False and message_erreur_main == None and '--skip-test' not in liste_option_main:
      message_erreur_main, message_bis_main = install.cas_test()
#
# 4. ==> Bilan
#
  if message_erreur_main == None :
    print (message_bis_main)
  else :
    print ("\n", message_erreur_main)
    message_erreur_main = message_bis_main
#
  sys.exit(message_erreur_main)
