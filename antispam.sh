#! /bin/bash 
#realise par : MOHAMED AMINE KASMI


extraire_expediteur(){
  local chaine=$(sed -n 2p  $1) #prendre la deuxieme ligne du fichier passer en argument
  echo "$chaine"
}
#extraire_expediteur fichier

extraire_objet(){
  local chaine=$(sed -n 3p  $1) #prendre la troisieme ligne du fichier passer en argument
  echo "$chaine"
}
#extraire_objet fichier

verifier_si_email(){
  local chaine=$(head -n 1 $1) #prendre la premiere ligne du fichier passer en argument
  local var="#email"
  if [ "$chaine" = "$var" ]; then # si la premier ligne est bien "#email"
     
     return 0
  else
     return 1
  fi
}
#verifier_si_email fichier

declare -a bloques

recuperer_expediteurs_bloques(){ 
  
 while read line || [ -n "$line" ]; #lire chaque ligne du fichier .expblo
  do   
  bloques+=($line) #ajouter chaque ligne au tableau
  done < .expblo   
    
}
#recuperer_expediteurs_bloques

declare -a mots
declare -a poids 

recuperer_mots_poids(){
   
  while read line || [ -n "$line" ]; #lire chaque ligne du fichier .expblo
   do 

    string=$(echo $line | cut -d' ' -f 2) #couper la ligne en utilisant espace comme delimiteur et renvoie le deuxieme element

    mots+=(${line%% *}) #coupe la ligne a partir de l espace
    
    poids+=($string)
   done < .motsup

}
#recuperer_mots_poids

verifier_si_expediteur_bloque(){
recuperer_expediteurs_bloques #appel de la fonction pour utiliser le tableau
key="$1"


if  ! [[ "${bloques[*]}" =~ "$key" ]]; then # verifier si l'adresse mail passe en argument existe dans le tableau des expediteurs bloques
    
  return 1

fi

return 0

}
#verifier_si_expediteur_bloque sender

deppasement_du_seuil(){

 recuperer_mots_poids #appel de la fonction pour utliser les deux tableau
 sub=$(extraire_objet $1) #appel de la fonction pour extraire l'objet du fichier passe en argument
 IFS=' ' read -r -a array <<< "$sub" #diviser l'objet par espace et mettre chaque mot dans le tableau array

 length1=$((${#array[@]}  - 1 )) #variable pour etre utiliser comme limiteur de la boucle
 length2=$((${#mots[@]}  - 1 ))  #variable pour etre utiliser comme limiteur de la boucle
 sum=0
 i=0
 j=0
  while [ $i -le $length1 ]; #boucle pour traverser le tableau array
   do 
    while [ $j -le $length2 ]; # boucle pour traverser le tableau mots
      do
       if [ "${array[$i]}" == "${mots[$j]}" ]; #tester si chaque mot de objet est dans le tableau des mots
        then
          sum=$(($sum + ${poids[$j]})) #si l mot existe, on ajoute son poids au variable sum
          j=$(($j + 1 ))
               
        else
          j=$(($j + 1 ))
        fi
      done
    j=0  
    i=$(($i + 1 ))    
   done
   if [ $sum -ge 60 ]; then #tester si la seuil depasse 60
      return 0 
    else 
      return 1
    fi
 }
#deppasement_du_seuil fichier

classer_email(){

  local sender=$(extraire_expediteur $1) #appel de la fonction pour extraire l'expediteur
  if verifier_si_expediteur_bloque $sender ;then 
   echo "BLOCKED"
  
  
  elif deppasement_du_seuil $1 ; then
   echo "SUSPECT"
  else 
  echo "CLEAN"
  fi
  
}
#classer_email fichier


classer_tous_emails(){
  local blck="BLOCKED"
  local sus="SUSPECT"
  local cln="CLEAN"
  for file in *;#boucle pour traverser tout les fichiers du repertoire courant
   do
     if ! verifier_si_email $file ; then #appel de la fonction pour utiliser son resultat boolean
     echo "this" $file "is not an email" 
     else
      local str=$(classer_email $file) #appel de la fonction pour utiliser son resultat chaine de character
      if [ "$str" = "$blck" ];then
      mv $file BLOCKED
      elif [ "$str" = "$sus" ] ; then
      mv $file SUSPECT
      elif [ "$str" = "$cln" ] ; then
      mv $file CLEAN
      fi
     fi 
  done
}
#classer_tous_emails


creer_repertoires(){
  if [[ ! -e $BLOCKED ]]; then #si le repertoir n'existe pas elle cree ce repertoir
    mkdir BLOCKED
  fi
  if [[ ! -e $SUSPECT ]]; then
    mkdir SUSPECT
  fi
  if [[ ! -e $CLEAN ]]; then
    mkdir CLEAN
  fi
  }
#creer_repertoires


tester_existence_fichiers(){
  local file1=".expblo"
  local file2=".motsup"
  if [[ ! -e $file1 ]]; then #si le fichier n'existe pas le programme echoue
    exit 1
  fi
  if [[ ! -e $file2 ]]; then
    exit 1
  fi
}
#tester_existence_fichiers


echoue_si_creation_impossible(){ #fonction ajoutee pour conformer a consigne de la derniere question, le programme echoue si la creation des repertoirs est impossible

  if ! [ -d "BLOCKED" ] ;  #si le repertoir n'existe pas le programme echoue
then exit 1
  elif ! [ -d "SUSPECT" ] ;
  then exit 1
  elif ! [ -d "CLEAN" ] ;
  then exit 1
  else
  return 0
  fi


}
#echoue_si_creation_impossible


main_program(){ #programme principal 
  tester_existence_fichiers
  creer_repertoires
  echoue_si_creation_impossible
  classer_tous_emails

}
#main_program