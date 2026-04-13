<h1 align="center">Active Directory Lab — Windows Server 2025</h1>

<p align="center">
  Documentação técnica de uma infraestrutura AD montada do zero, simulando o ambiente 
  de TI de uma empresa com sede em Caxambu. Cada decisão está registrada com o 
  raciocínio por trás dela.
</p>

---

## 🛠️ Stack do Lab

![Windows Server](https://img.shields.io/badge/Windows_Server_2025-0078D4?style=for-the-badge&logo=windows&logoColor=white)
![Active Directory](https://img.shields.io/badge/Active_Directory-003366?style=for-the-badge&logo=microsoft&logoColor=white)
![Hyper-V](https://img.shields.io/badge/Hyper--V-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![DNS](https://img.shields.io/badge/DNS_Server-005571?style=for-the-badge&logo=cloudflare&logoColor=white)
![Kerberos](https://img.shields.io/badge/Kerberos-Auth-CC0000?style=for-the-badge&logo=keycdn&logoColor=white)
![SMB](https://img.shields.io/badge/File_Server_SMB-217346?style=for-the-badge&logo=files&logoColor=white)

| Componente | Detalhe |
|---|---|
| Hipervisor | Hyper-V (Windows 10 — host) |
| DC Principal | Windows Server 2025 — `SEU_HOSTNAME` (`10.10.10.10`) |
| DC Secundário | Windows Server 2025 — `SEU_HOSTNAME_2` (`10.10.10.20`) / RID Master |
| Cliente | Windows 10 (ingressado no domínio) |
| Domínio | `seudominio.internal` |
| Serviços | AD DS, DNS, GPO, File Server (NTFS/SMB), FSMO Roles |
| Automação | PowerShell + CSV |

---

## 📋 Índice

| # | O que está documentado | Status |
|---|---|---|
| [01](#1-estrutura-de-ous) | Estrutura de Unidades Organizacionais (OUs) | ✅ Feito |
| [02](#2-grupos-de-segurança--metodologia-agdlp) | Grupos de Segurança — Metodologia AGDLP | ✅ Feito |
| [03](#3-automação-de-usuários-via-powershell) | Automação de Usuários via PowerShell | ✅ Feito |
| [04](#4-gpo--bloqueio-de-painel-de-controle) | GPO — Bloqueio de Painel de Controle | ✅ Feito |
| [05](#5-gpo--bloqueio-de-usb-dlp) | GPO — Bloqueio de USB (DLP) | ✅ Feito |
| [06](#6-servidor-de-arquivos-e-permissões-ntfs) | Servidor de Arquivos e Permissões NTFS | ✅ Feito |
| [07](#7-segundo-dc-e-alta-disponibilidade) | Segundo DC e Alta Disponibilidade | ✅ Feito |
| [08](#8-topologia-multi-site-e-replicação) | Topologia Multi-Site e Replicação | ✅ Feito |
| [09](#9-hardening--protected-users-e-auditoria) | Hardening — Protected Users e Auditoria | ✅ Feito |
| [10](#10-controle-de-acesso-remoto-rdp-via-gpo) | Controle de Acesso Remoto (RDP via GPO) | ✅ Feito |
| [11](#próximos-passos) | Próximos Passos | 🔄 Em andamento |

---

## Implementação

---

### 1. Estrutura de OUs

O primeiro passo foi largar os containers padrão do Windows e criar uma hierarquia própria. Isso é necessário para aplicar GPOs de forma granular — container padrão não aceita GPO diretamente.

**Estrutura criada:**
- `Matriz-Caxambu` (raiz da organização)
  - `ADM` — políticas e usuários administrativos
  - `TI` — políticas específicas de tecnologia
  - `COMPUTADORES` — objetos de máquina para hardening de estações

| Evidência | Descrição |
|---|---|
| ![Árvore de OUs](img/Arvore1.png) | Visão expandida da hierarquia |
| ![Árvore de OUs](img/Arvore.png) | Visão no ADUC |

---

### 2. Grupos de Segurança — Metodologia AGDLP

Optei por grupos globais em vez de adicionar usuários direto nas permissões. O motivo é simples: quando alguém sai da empresa, você remove do grupo e acabou — não precisa caçar permissão por permissão.

- **Grupo criado:** `G_TI_AcessoFull` (escopo: Global)
- O usuário `robson.silva` foi movido para a OU correta e vinculado ao grupo, não à pasta diretamente.

| Evidência | Descrição |
|---|---|
| ![Membros do Grupo](img/MembroDe.png) | Usuário vinculado ao grupo |
| ![Grupo G_TI](img/MembroGTI.png) | Configuração do grupo G_TI_AcessoFull |

---

### 3. Automação de Usuários via PowerShell

Criar usuário por usuário no ADUC não escala. Escrevi um script que lê um CSV (simulando exportação do RH) e provisiona as contas automaticamente nas OUs certas.

**[→ Script completo e CSV base disponíveis em `/Scripts`](./Scripts/)**

O script lê o CSV linha por linha, identifica o campo `Departamento` e cria o usuário na OU correspondente (`ADM` ou `TI`). Se o departamento não bater com nenhuma OU cadastrada, ele pula o registro e loga o erro. Senhas temporárias são geradas via `SecureString` com a flag de troca obrigatória no primeiro logon.

| Evidência | Descrição |
|---|---|
| ![PS1](img/PS1.png) | Criação do arquivo CSV na pasta Scripts |
| ![PS2](img/PS2.png) | Preenchimento dos dados no CSV |
| ![PS3](img/PS3.png) | Execução do script via PowerShell |
| ![PS4](img/PS4.png) | Resultado no AD — pasta ADM |
| ![PS5](img/PS5.png) | Resultado no AD — pasta TI |

---

### 4. GPO — Bloqueio de Painel de Controle

Primeira política de hardening aplicada. O objetivo é impedir que o usuário final mexa nas configurações do SO — principal causa de chamados por desconfiguração.

- **Política:** Bloqueio de Painel de Controle e Configurações do Sistema
- **Escopo:** OU `TI` (aplicada aqui primeiro para homologação antes de expandir)
- **Validação:** `gpupdate /force` na estação cliente confirmou a aplicação

| Evidência | Descrição |
|---|---|
| ![Criando Política](img/CriandoPoliticaTI.png) | Criação da GPO no GPMC |
| ![Proibindo Acesso](img/ProibindoAcessoPainelEConf.png) | Configuração da restrição |
| ![Abrindo Painel](img/AbrindoPainel.png) | Tentativa de acesso pelo usuário |
| ![Painel Bloqueado](img/PainelEConfBloq.png) | Bloqueio confirmado |

---

### 5. GPO — Bloqueio de USB (DLP)

Pen drive é uma das formas mais simples de vazar dados ou introduzir malware. Essa política resolve no nível de máquina — não importa quem fizer logon.

- **Política:** *All Removable Storage classes: Deny all access*
- **Escopo:** OU `COMPUTADORES`
- O objeto de computador da estação Windows 10 foi movido do container padrão para a OU para receber a diretiva

| Evidência | Descrição |
|---|---|
| ![USB1](img/USB1.png) | Máquina movida para OU de Computadores |
| ![USB2](img/USB2.png) | Regra ativa no servidor |
| ![USB3](img/USB3.png) | Bloqueio ao tentar acessar unidade removível |

---

### 6. Servidor de Arquivos e Permissões NTFS

A lógica aqui é o modelo das "duas portas": compartilhamento (Share) aberto para o grupo de TI, e o controle real acontece na camada NTFS.

**O que foi feito:**
- Pasta `TI_Confidencial` criada em `C:\Arquivo_Matriz\`
- Herança desabilitada — cada pasta departamental tem controle independente
- Permissão `Modify` para `G_TI_AcessoFull` — o grupo trabalha normalmente mas não controla as configurações de segurança da pasta

`Modify` em vez de `Full Control` é intencional: o usuário não pode alterar permissões NTFS nem se apoderar do objeto. Ele faz o trabalho dele, o controle fica com o administrador.

| Evidência | Descrição |
|---|---|
| ![NTFS1](img/NTFS1.png) | Criação de `C:\Arquivo_Matriz\TI_Confidencial` |
| ![NTFS2](img/NTFS2.png) | Adicionando grupo `G_TI_AcessoFull` |
| ![NTFS3](img/NTFS3.png) | Permissão `Modify` configurada |
| ![NTFS4](img/NTFS4.png) | Herança desabilitada, usuários individuais removidos |
| ![NTFS5](img/NTFS5.png) | Unidade de rede mapeada na estação Windows 10 |

---

### 7. Segundo DC e Alta Disponibilidade

> 📸 *Evidências desta seção em `/docs`*
> 
> ⚠️ **[PREENCHER: adicione as imagens e detalhes desta implementação]**

Um único DC é um ponto único de falha. Se ele cair, ninguém autentica. A solução foi promover um segundo servidor ao papel de Domain Controller e transferir a função **RID Master** para ele.

- **DC Principal:** `SEU_HOSTNAME` (`10.10.10.10`) — DC primário e DNS Server
- **DC Secundário:** `SEU_HOSTNAME_2` (`10.10.10.20`) — DC de redundância + RID Master
- **Troubleshooting realizado:** falhas de resolução de nomes corrigidas via `nslookup` e diagnóstico de gateway

---

### 8. Topologia Multi-Site e Replicação

> ⚠️ **[PREENCHER: adicione as imagens e detalhes desta implementação]**

Criação de Site no AD para simular latência e controlar o tráfego de replicação entre localidades. Sem isso, o AD replica sem critério e gera congestionamento em links lentos.

- **Site criado:** `SEU_SITE_NAME`
- **Sub-rede associada:** `172.16.1.0/24`
- **Objetivo:** autenticação de usuários sempre pelo DC mais próximo geograficamente

---

### 9. Hardening — Protected Users e Auditoria

> ⚠️ **[PREENCHER: adicione as imagens e detalhes desta implementação]**

**Protected Users** é um grupo especial do AD que força o uso de Kerberos e elimina cache de credenciais NTLM. Contas administrativas incluídas nele não funcionam com protocolos de autenticação legados.

Também foi ativada a política **"Deny Logon as a Service"** para contas admin — impede que malware use uma conta comprometida para se registrar como serviço e persistir no sistema.

**Auditoria ativada:**
- Eventos de gestão de contas (criação, exclusão, alteração de senha)
- Rastreabilidade total de modificações no diretório

---

### 10. Controle de Acesso Remoto (RDP via GPO)

> ⚠️ **[PREENCHER: adicione as imagens e detalhes desta implementação]**

RDP aberto para todos é risco de movimentação lateral. A GPO criada restringe o acesso via Remote Desktop apenas ao grupo de TI autorizado, bloqueando qualquer outra conta — incluindo administradores locais.

---

## Próximos Passos

- [x] Estrutura de OUs e grupos de segurança (AGDLP)
- [x] GPOs de hardening (USB, Painel de Controle)
- [x] Servidor de Arquivos com permissões NTFS granulares
- [x] Automação de onboarding via PowerShell
- [x] Segundo DC e alta disponibilidade
- [x] Topologia Multi-Site e replicação
- [x] Protected Users e auditoria de eventos
- [x] Controle de RDP via GPO
- [ ] Account Lockout Policy e política de complexidade de senhas
- [ ] Mapeamento automático de unidades de rede via GPO por departamento
- [ ] Avaliação de sincronização com Azure AD (Entra ID)

---

## 📂 Estrutura do Repositório
/docs      → diagramas de rede e evidências de configuração
/scripts   → scripts PowerShell e arquivos CSV
/config    → detalhes e backups das GPOs aplicadas