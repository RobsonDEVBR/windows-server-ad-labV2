# 1. Importar o módulo do Active Directory
Import-Module ActiveDirectory

# 2. Definir a senha padrão temporária para todos
$senhaPadrao = ConvertTo-SecureString "Mudar@123" -AsPlainText -Force

# 3. Ler o arquivo CSV criado pelo RH
$usuarios = Import-Csv -Path "C:\Scripts\novos_usuarios.csv" -Delimiter ";"

# 4. O laço de repetição (Loop) para criar cada usuário
foreach ($user in $usuarios) {
    
    # Define em qual OU (pasta) o usuário vai cair, dependendo do departamento no CSV
    if ($user.Departamento -eq "TI") {
        $caminhoOU = "OU=TI,OU=Matriz-Caxambu,DC=robson,DC=local"
    } else {
        $caminhoOU = "OU=ADM,OU=Matriz-Caxambu,DC=robson,DC=local"
    }

    # O comando que efetivamente cria o usuário no AD
    New-ADUser -Name "$($user.Nome) $($user.Sobrenome)" `
               -GivenName $user.Nome `
               -Surname $user.Sobrenome `
               -SamAccountName $user.Login `
               -UserPrincipalName "$($user.Login)@robson.local" `
               -Path $caminhoOU `
               -AccountPassword $senhaPadrao `
               -Enabled $true `
               -ChangePasswordAtLogon $true

    # Imprime na tela o aviso de sucesso
    Write-Host "Usuário $($user.Login) criado com sucesso na OU $($user.Departamento)!" -ForegroundColor Green
}