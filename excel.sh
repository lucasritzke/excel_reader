#!/usr/bin/env bash
#
clear
DATE="date +%y-%m-%d_%H:%M"
USER=$("whoami")
#Entering with argument or without
if [ $# -eq 0 ]; then
echo "Qual o caminho do arquivo .CSV?"
cd /home/$USER
ls -R
read input_file
clear
else
        input_file=$1
fi

#Starts by doing an if that checks if the file is in .CSV format
if ! echo "$input_file" | grep -Eq '^*.CSV$|^*.csv$'; then
        echo "O arquivo informado não é um arquivo *.CSV, ou *.csv!"
        exit 1
fi
#Checking that all information is in correct syntax
while read -r liner; do
        #ignore first line
        if [[ $liner == "User name"* ]]; then
                continue
        fi
        #Checking email sintax
email=$(echo "$liner" | awk -F ';' '{print $8}' | sed 's/ //g')
if ! echo "$email" | grep -Eq '^([a-z\d_\-\.]{1,30})@([a-z\d_\-]{1,20})\.([a-z]{2,8})(\.[a-z]{2,8})?$'; then
        echo "sintaxe de email ($email) incorreta"
                exit 1
        fi
        #Checking user_id sintax
        os_name=$(echo "$liner" | awk -F ';' '{print $3}' | sed 's/^\s+//; s/\s+$//')
        if ! echo "$os_name" | grep -Eq '^[A-Za-z0-9]+$'; then
                echo "sintaxe ($os_name) incorreta"
                exit 1
        fi
        #Checking Group sintax
        Group=$(echo "$liner" | awk -F ';' '{print $4}' | sed 's/^\s+//; s/\s+$//;  s/\./_/g')
        if ! echo "$Group" | grep -Eq '^[A-Za-z0-9]+[-_][A-Za-z0-9]+[-_][A-Za-z0-9]+(_[A-Za-z0-9]+)*$'; then
                echo "sintaxe ($Group) incorreta"
                exit 1
        fi
        #Checking Role sintax
        Role=$(echo "$liner" | awk -F ';' '{print $5}' | sed 's/^\s+//; s/\s+$//')
        if ! echo "$Role" | grep -Eq '^[a-zA-Z0-9]+(\-[a-zA-Z0-9]+)*$'; then
                echo "sintaxe ($Role) incorreta"
                exit 1
        fi
        #Checking Departament sintax
        Departament=$(echo "$liner" | awk -F ';' '{print $7}' | sed 's/\//_/g; s/^\s+//; s/\s+$//')
        if ! echo "$Departament" | grep -Eq '^[A-Z0-9]{2,}_[A-Z0-9]{2,}$'; then
                echo "sintaxe ($Departament) incorreta"
                exit 1
        fi
        #Checking Volume sintax
         Volume=$(echo "$liner" | awk -F ';' '{print $10}' | sed 's/^\s+//; s/\s+$//')
         if ! echo "$Volume" | grep -Eq '^[a-z]+_[a-z]+$'; then
                 echo "sintaxe ($Volume) incorreta"
                 exit 1
         fi
#End while
done < $input_file
#Starts the loop

clear
log_message+="#--------------------------------------------------------------------------\n"
while read -r line; do
        #Search values from username
        if [[ $line == "User name"* ]]; then
                continue
        fi
        #Checks if the username returns empty to the loop
        username=$(echo $line | awk -F'\t' '{print $1}' | sed 's/ /_/g; s/,//g' | cut -d ';' -f 1)
        if [[ -n $username ]]; then

        activ=$(echo "$line" | awk -F ';' '{print $11}')
        #Check whether the user is active or not

        if ! echo "$activ" | grep -Eq '^[0-1]$'; then
                echo -e  "A coluna active tem um valor desconhecido!\nA coluna active deve ter números como 0 para usuários ativos e 1 para usuários inátivos\nNenhuma alteração foi feita!"
                log_message+="A coluna active tem um valor desconhecido!\nA coluna active deve ter números como 0 para usuários ativos e 1 para usuários inátivos\nNenhuma alteração foi feita!\n"
                exit 1

        elif [[ $activ -eq 1 ]]; then
                path="/home/$USER/files_dir/$username"
                if [ -d $path ]; then
                        sudo rm -rf "$path"
                        echo "O usuário $username Foi removido pois está inativo!"
                        log_message+="O usuário $username Foi removido pois está inativo!\n"
                else
                        echo "O usuário $username não foi adicionado pois está inativo!"
                        log_message+="O usuário $username não foi adicionado pois está inativo!\n"
                fi
        elif [[ $activ -eq 0 ]]; then
        #Start declaring variables
        teamcenter_id=$(echo "$line" | awk -F ',' '{print $2}' | sed 's/^\s+//; s/\s+$//')
        os_name=$(echo "$line" | awk -F ';' '{print $3}' | sed 's/^\s+//; s/\s+$//')
        Group=$(echo "$line" | awk -F ';' '{print $4}' | sed 's/^\s+//; s/\s+$//;  s/\./_/g; s/ /_/g')
        Role=$(echo "$line" | awk -F ';' '{print $5}' | sed 's/^\s+//; s/\s+$//; s/ /_/g')
        email=$(echo "$line" | awk -F ';' '{print $8}' | sed 's/^\s+//; s/\s+$//; s/ /_/g')
        Departament=$(echo "$line" | awk -F ';' '{print $7}' | sed 's/\//_/g; s/^\s+//; s/\s+$//; s/ /_/g')
        Volume=$(echo "$line" | awk -F ';' '{print $10}' | sed 's/^\s+//; s/\s+$//; s/ /_/g')
        #Declare variables
        dir_Create="/home/$USER/files_dir"
        dir_User="/home/$USER/files_dir/$username"
        dir_subUser="/home/$USER/files_dir/$username/$os_name"
        file_Group="/home/$USER/files_dir/$username/$os_name/$Group"
        file_Role="/home/$USER/files_dir/$username/$os_name/$Role"
        file_Depart="/home/$USER/files_dir/$username/$os_name/$Departament"
        file_Volum="/home/$USER/files_dir/$username/$os_name/$Volume" 

        #Starts creating directories and files
        if [ ! -e "$dir_Create" ]; then
                sudo mkdir "$dir_Create" && sudo chown $USER:$USER "$dir_Create"
                echo -e "Diretório $dir_Create criado\n"
                log_message+="Diretório $dir_Create criado\n"
        fi

        if [[ ! -e "$dir_User" ]]; then
                sudo mkdir "/home/$USER/files_dir/$username" && sudo chown $USER:$USER "/home/$USER/files_dir/$username"
                echo -e "\nDiretório $dir_User Criado"
                log_message+="\nDiretório $dir_User Criado\n"
        fi

        if [[ ! -e "$dir_subUser" ]]; then
                sudo mkdir "/home/$USER/files_dir/$username/$os_name" && sudo chown $USER:$USER "/home/$USER/files_dir/$username/$os_name"
                echo -e "Diretório $dir_subUser criado"
                log_message+="Diretório $dir_subUser criado\n"
        fi

created_items=()
variables=("$file_Group" "$file_Role" "$file_Depart" "$file_Volum")
        for item in "${variables[@]}"
        do
                while [ ! -e "$item" ]
                do
                        if [[ "$item" == dir* ]];
                        then
                                sudo mkdir "$item"
                                created_items+=("$item")
# Adiciona o nome do diretório criado à ArrayList echo "Diretório $item criado."
                        else
                                sudo touch "$item" && sudo chown $USER:$USER "$item"
                                created_items+=("$item")
# Adiciona o nome do arquivo criado à ArrayList echo "Arquivo $item criado."
                        fi
                done
        done
if [ ${#created_items[@]} -eq 0 ]; then
        echo "Nunhum item foi criado"
        log_message+="Nenhum arquivo foi criado\n"
else
# Mostra os itens criados echo "Itens criados:"
        for item in "${created_items[@]}"
        do
                echo -e "\nArquivos criados - $item"
                log_message+="\nArquivos criados - $item"
        done
fi

#Additional() {
#I've already left everything ready to hear a request for a new feature
        #idefault_group=$(echo "$line" | awk -F ';' '{print $6}' | sed 's/ //g')
        #licensing_lever=$(echo "$line" | awk -F ';' '{print $9}' | sed 's/ //g')
        #sudo touch "/home/$USER/files_dir/$username/$os_name/$default_group"
        #sudo touch "/home/$USER/files_dir/$username/$os_name/$licensing_lever"
        #sudo touch "/home/$USER/files_dir/$username/$os_name/$email"
#}
        #Declares a text for the user

#If the users is inactive, the program will not create his record.
#activ else
        else
                echo "Erro desconhecido Activ"
                log_message+="Erro desconhecido no laço activ\n"
                exit 1
        fi
#Username else
        else
                log_message+="Arquivo com linha vazia o script continuou sem erros\n"
        fi
        done < "$input_file"
        log_message+="#--------------------------------------------------------------------------"
        if [[ ! -d "/home/$USER/log_dir" ]]; then
                sudo mkdir -p "/home/$USER/log_dir" && sudo chown $USER:$USER "/home/$USER/log_dir"
        fi

        name_file=$(basename "$input_file")
        name_log=$(echo $name_file | sed 's/[Cc][Ss][Vv]//g; s/\./_/g; s/ /_/g')
        final_name="${name_log}$($DATE).log"
        if [[ ! -f "/home/$USER/log_dir/$final_name" ]]; then
                sudo touch "/home/$USER/log_dir/$final_name" && sudo chown $USER:$USER "/home/$USER/log_dir/$final_name"
        fi
        log_message+="\nTudo ocorreu corretamente, Script executado em $($DATE)"
log_text=$(echo $message | sed 's/_/ /g')
message=$(echo -e  "$log_message")
path_log="/home/$USER/log_dir/$final_name"
echo "$message" > "$path_log"

