<h1 align="center">Active Directory Lab — Windows Server 2025</h1>

<p align="center">
  Documentação técnica de uma infraestrutura corporativa montada do zero em laboratório,<br>
  simulando o ambiente de TI de uma empresa multi-site com sede em Caxambu e filial em Belo Horizonte.<br>
  Cada decisão de arquitetura está registrada com o raciocínio por trás dela.
</p>

<p align="center">
  <a href="#️-stack-do-lab">Stack</a> •
  <a href="#-topologia-da-infraestrutura">Topologia</a> •
  <a href="#-índice">Índice</a> •
  <a href="#-fase-1-fundação-topologia-e-automação">Fase 1</a> •
  <a href="#-fase-2-segurança-hardening-e-governança-gpo">Fase 2</a> •
  <a href="#-fase-3-serviços-de-arquivos-storage-avançado-e-governança">Fase 3</a> •
  <a href="#️-próximos-passos">Roadmap</a>
</p>

---

## 🛠️ Stack do Lab

### Plataforma & Virtualização
![Windows Server 2025](https://img.shields.io/badge/Windows_Server_2025-0078D4?style=for-the-badge&logo=windows&logoColor=white)
![Hyper-V](https://img.shields.io/badge/Hyper--V-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Windows 10](https://img.shields.io/badge/Windows_10_Client-0078D4?style=for-the-badge&logo=windows&logoColor=white)

### Identidade & Diretório
![Active Directory](https://img.shields.io/badge/Active_Directory_DS-003366?style=for-the-badge&logo=microsoft&logoColor=white)
![DNS Server](https://img.shields.io/badge/DNS_Server-005571?style=for-the-badge&logo=cloudflare&logoColor=white)
![Kerberos](https://img.shields.io/badge/Kerberos_Auth-CC0000?style=for-the-badge&logo=keycdn&logoColor=white)
![FSMO](https://img.shields.io/badge/FSMO_Roles-003366?style=for-the-badge&logo=microsoft&logoColor=white)
![NTP](https://img.shields.io/badge/NTP_w32tm-555555?style=for-the-badge&logo=clockify&logoColor=white)

### Storage & File Services
![File Server SMB](https://img.shields.io/badge/File_Server_SMB-217346?style=for-the-badge&logo=files&logoColor=white)
![Storage Spaces](https://img.shields.io/badge/Storage_Spaces-0078D4?style=for-the-badge&logo=databricks&logoColor=white)
![DFS](https://img.shields.io/badge/DFS_Namespaces-217346?style=for-the-badge&logo=microsoftsharepoint&logoColor=white)
![FSRM](https://img.shields.io/badge/FSRM-CC6600?style=for-the-badge&logo=files&logoColor=white)
![Data Dedup](https://img.shields.io/badge/Data_Deduplication-007ACC?style=for-the-badge&logo=databricks&logoColor=white)
![SMB Multichannel](https://img.shields.io/badge/SMB_Multichannel-217346?style=for-the-badge&logo=speedtest&logoColor=white)

### Segurança & Governança
![GPO](https://img.shields.io/badge/Group_Policy_GPO-003366?style=for-the-badge&logo=microsoft&logoColor=white)
![NTFS](https://img.shields.io/badge/NTFS_Permissions-555555?style=for-the-badge&logo=files&logoColor=white)
![RBAC](https://img.shields.io/badge/RBAC_PoLP-CC0000?style=for-the-badge&logo=keycdn&logoColor=white)
![ABE](https://img.shields.io/badge/ABE_Access--Based_Enum-007ACC?style=for-the-badge&logo=shield&logoColor=white)
![Protected Users](https://img.shields.io/badge/Protected_Users-CC0000?style=for-the-badge&logo=keycdn&logoColor=white)

### Automação
![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![CSV](https://img.shields.io/badge/CSV_Import-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white)

---

## 🗺️ Topologia da Infraestrutura

| Node | Hostname | IP | Função Principal |
|------|----------|----|-----------------|
| DC Principal | `CXB-DC01` | `10.10.10.10` | AD DS, DNS, PDC Emulator, Schema Master, Domain Naming Master, Infrastructure Master |
| DC Secundário | `CXB-DC02` | `10.10.10.20` | AD DS, DNS, RID Master |
| File Server | `CXB-FS01` | `10.10.10.30` | File Server SMB, Storage Spaces, DFS-N, FSRM, Data Dedup, ABE |
| Cliente | `WIN10` | DHCP | Estação Windows 10 ingressada no domínio `robson.local` |
| Hipervisor | Host | — | Windows 10 + Hyper-V |

| Site | Sub-rede | Servidores |
|------|----------|-----------|
| Matriz-Caxambu | `10.10.10.0/24` | `CXB-DC01`, `CXB-FS01`, `WIN10` |
| BeloHorizonte | `172.16.1.0/24` | `CXB-DC02` |

---

## 📋 Índice

| Fase | Item | Status |
|------|------|--------|
| 🟢 Fase 1 | [Estrutura de OUs](#1-estrutura-de-ous) | ✅ Concluído |
| 🟢 Fase 1 | [Automação de Usuários via PowerShell](#2-automação-de-usuários-via-powershell) | ✅ Concluído |
| 🟢 Fase 1 | [Alta Disponibilidade — DC Secundário (CXB-DC02)](#3-alta-disponibilidade--dc-secundário-cxb-dc02) | ✅ Concluído |
| 🟢 Fase 1 | [Design Multi-Site e Replicação](#4-design-multi-site-e-replicação) | ✅ Concluído |
| 🟢 Fase 1 | [Gestão de Roles FSMO](#5-gestão-de-roles-fsmo) | ✅ Concluído |
| 🟢 Fase 1 | [Troubleshooting: Renomeando DCs + Fix NTP](docs/troubleshooting_rename_dc.md) | ✅ Concluído |
| 🔐 Fase 2 | [Grupos de Segurança — Metodologia AGDLP](#7-grupos-de-segurança--metodologia-agdlp) | ✅ Concluído |
| 🔐 Fase 2 | [GPO — Bloqueio de Painel de Controle](#8-gpo--bloqueio-de-painel-de-controle) | ✅ Concluído |
| 🔐 Fase 2 | [GPO — Bloqueio de USB (DLP)](#9-gpo--bloqueio-de-usb-dlp) | ✅ Concluído |
| 🔐 Fase 2 | [Hardening — Protected Users](#10-hardening--protected-users) | ✅ Concluído |
| 🔐 Fase 2 | [Delegação de Privilégios (RBAC)](#11-delegação-de-privilégios-rbac-e-segregação-de-funções) | ✅ Concluído |
| 🔐 Fase 2 | [Atribuição de Direitos — Deny Logon as a Service](#12-atribuição-de-direitos--deny-logon-as-a-service) | ⚠️ Em documentação |
| 🔐 Fase 2 | [Auditoria Avançada de Eventos](#13-auditoria-avançada-de-eventos) | ⚠️ Em documentação |
| 🔐 Fase 2 | [GPO — Account Lockout e Política de Senhas](#14-gpo--account-lockout-e-política-de-senhas) | ⚠️ Em documentação |
| 📂 Fase 3 | [Servidor de Arquivos e Permissões NTFS](#15-servidor-de-arquivos-e-permissões-ntfs) | ✅ Concluído |
| 📂 Fase 3 | [CXB-FS01 — Storage Spaces (Arquitetura Base)](#️-cxb-fs01--storage-spaces-arquitetura-base-do-servidor-de-arquivos) | ✅ Concluído |
| 📂 Fase 3 | [Estrutura de Dados: Dedup e DFS-N](docs/fase3-storage-governança/fase3-storage-governança.md) | ⚠️ Em documentação |
| 📂 Fase 3 | [Governança: FSRM, NTFS e ABE](docs/fase3-storage-governança/fase3-storage-governança.md) | ⚠️ Em documentação |
| 📂 Fase 3 | [Mapeamento Automático de Unidades via GPO](#16-mapeamento-automático-de-unidades-via-gpo) | ⚠️ Em documentação |
| 📂 Fase 3 | [Print Server e Automação (GPO)](#16-mapeamento-automático-de-unidades-via-gpo) | ⚠️ Em documentação |
| 📂 Fase 3 | [Conectividade Matriz/Filial (DFS-R, VPN & BranchCache)](docs/fase3-conectividade-filial/fase3-conectividade-filial.md) | ⚠️ Em documentação |
| 📂 Fase 3 | [Disaster Recovery (WAC, VSS e Backup)](docs/fase3-disaster-recovery/fase3-disaster-recovery.md) | ⚠️ Em documentação |
| ☁️ Fase 4 | [Próximos Passos](#️-próximos-passos) | 🔄 Planejado |

---

## 🟢 Fase 1: Fundação, Topologia e Automação

---

### 1. Estrutura de OUs

O primeiro passo foi abandonar os containers padrão do Windows e criar uma hierarquia de OUs customizada. Containers padrão (`Computers`, `Users`) não suportam GPO diretamente — uma OU é o pré-requisito para qualquer política granular.

**Estrutura criada:**

```
robson.local
├── Matriz-Caxambu          ← Raiz da organização principal
│   ├── ADM                 ← Usuários e políticas administrativas
│   ├── TI                  ← Usuários e políticas de tecnologia
│   └── COMPUTADORES        ← Objetos de máquina (hardening de estações)
└── BeloHorizonte           ← Filial BH
    ├── ADM
    ├── TI
    └── COMPUTADORES
```

| Evidência | Descrição |
|-----------|-----------|
| [![Árvore de OUs](img/Arvore1.png)](img/Arvore1.png) | Visão expandida da hierarquia no ADUC |
| [![Árvore de OUs](img/Arvore.png)](img/Arvore.png) | Visão condensada da hierarquia |
| [![BeloHorizonte Filial](img/UO.png)](img/UO.png) | OU da Filial BeloHorizonte no ADUC |

---

### 2. Automação de Usuários via PowerShell

Provisionar usuário por usuário no ADUC não escala. O script lê um CSV simulando uma exportação do RH e provisiona as contas automaticamente nas OUs corretas, com tratamento de erro e senhas seguras.

**[→ Script e CSV disponíveis em `/Scripts`](Scripts)**

**Lógica do script:**
- Lê o CSV linha por linha e identifica o campo `Departamento`
- Cria o usuário na OU correspondente (`ADM` ou `TI`)
- Registros com departamento não mapeado são pulados e logados como erro
- Senhas geradas via `SecureString` com flag de troca obrigatória no primeiro logon

| Arquivo | Descrição |
|---------|-----------|
| `Scripts/CriarUsuarios.ps1` | Script de provisionamento automatizado |
| `Scripts/novos_usuarios.csv` | Modelo de entrada de dados (simula exportação do RH) |

| Evidência | Descrição |
|-----------|-----------|
| [![PS1](img/PS1.png)](img/PS1.png) | Criação do arquivo CSV na pasta Scripts |
| [![PS2](img/PS2.png)](img/PS2.png) | Preenchimento dos dados no CSV |
| [![PS3](img/PS3.png)](img/PS3.png) | Execução do script via PowerShell |
| [![PS4](img/PS4.png)](img/PS4.png) | Resultado no AD — OU ADM populada |
| [![PS5](img/PS5.png)](img/PS5.png) | Resultado no AD — OU TI populada |

---

### 3. Alta Disponibilidade — DC Secundário (CXB-DC02)

Um único DC é ponto único de falha total: se cair, nenhum usuário autentica, nenhuma GPO é aplicada e nenhum recurso de rede funciona. A solução foi promover `CXB-DC02` a Domain Controller, distribuindo o serviço de identidade entre dois servidores.

| Função | Servidor | IP |
|--------|----------|----|
| DC Principal | `CXB-DC01` | `10.10.10.10` — AD DS, DNS, PDC Emulator |
| DC Secundário | `CXB-DC02` | `10.10.10.20` — AD DS, DNS, RID Master |

> ℹ️ **Histórico:** Os servidores foram originalmente configurados como `SRV-DC01` e `MBR1`, e padronizados para `CXB-DC01` e `CXB-DC02`. O processo completo está em [docs/troubleshooting_rename_dc.md](docs/troubleshooting_rename_dc.md).

| Evidência | Descrição |
|-----------|-----------|
| [![MBR1.1](img/MBR1.1.png)](img/MBR1.1.png) | Configuração inicial do segundo DC |
| [![MBR1.2](img/MBR1.2.png)](img/MBR1.2.png) | Promoção a Domain Controller via wizard |
| [![MBR1.3](img/MBR1.3.png)](img/MBR1.3.png) | Configuração do DNS no DC Secundário |
| [![MBR1.4](img/MBR1.4.png)](img/MBR1.4.png) | Validação da replicação entre os DCs |
| [![MBR1.5](img/MBR1.5.png)](img/MBR1.5.png) | Confirmação de sincronização do AD |

---

### 4. Design Multi-Site e Replicação

Sem Sites configurados, o AD replica de forma indiscriminada — qualquer autenticação pode resolver para o DC mais distante geograficamente, gerando latência e congestionamento em links WAN. A configuração de Sites instrui o KCC (Knowledge Consistency Checker) a otimizar a topologia de replicação automaticamente.

- **Site Matriz-Caxambu:** sub-rede `10.10.10.0/24` — `CXB-DC01` e `CXB-FS01`
- **Site BeloHorizonte (BH):** sub-rede `172.16.1.0/24` — `CXB-DC02`
- **Objetivo:** autenticação sempre pelo DC geograficamente mais próximo do usuário

| Evidência | Descrição |
|-----------|-----------|
| [![SITES1](img/SITES1.png)](img/SITES1.png) | Active Directory Sites and Services |
| [![SITES3](img/SITES3.png)](img/SITES3.png) | Criação do Site BH |
| [![SITES2](img/SITES2.png)](img/SITES2.png) | Sub-rede `172.16.1.0/24` criada e associada ao Site BH |
| [![SITES4](img/SITES4.png)](img/SITES4.png) | Configuração do Site Link e custo de replicação |
| [![SITES5](img/SITES5.png)](img/SITES5.png) | `CXB-DC02` movido para o Site BH |
| [![SITES6](img/SITES6.png)](img/SITES6.png) | Sub-rede `10.10.10.0/24` vinculada ao Site Matriz |

> **Status atual:** topologia lógica validada no AD. Segregação física de rede no hypervisor (RRAS entre `10.x` e `172.x`) está planejada para a Fase 3 de Conectividade.

---

### 5. Gestão de Roles FSMO

O AD possui 5 roles FSMO que controlam operações que exigem autoridade única no domínio. Com dois DCs, é possível distribuir essas responsabilidades para evitar que um único servidor seja ponto crítico operacional.

A role **RID Master** foi transferida para `CXB-DC02`. Dessa forma, a criação de novos objetos (usuários, grupos, computadores) não depende exclusivamente do DC principal.

| Evidência | Descrição |
|-----------|-----------|
| [![TFSMO1](img/TFSMO1.png)](img/TFSMO1.png) | Abrindo o wizard de Transferência dos Operation Masters |
| [![TFSMO2](img/TFSMO2.png)](img/TFSMO2.png) | Confirmando a transferência do RID Master para `CXB-DC02` |
| [![TFSMO3](img/TFSMO3.png)](img/TFSMO3.png) | Validação via `netdom query fsmo` no CMD |

---

### 6. [Troubleshooting: Renomeando DCs (Zero Downtime) e Fix de NTP](docs/troubleshooting_rename_dc.md)

Documentação completa do processo de renomeação dos DCs sem interrupção de serviço. Cobre todas as etapas e problemas encontrados:

**Cenário:** padronização da nomenclatura para arquitetura multi-site.

| Antes | Depois |
|-------|--------|
| `SRV-DC01` | `CXB-DC01` |
| `MBR1` | `CXB-DC02` |

**Processo de renomeação via `netdom` (sem rebaixamento do DC):**

```powershell
# Etapa 1 — Adiciona o novo nome como apontamento alternativo no AD e DNS
netdom computername <servidor> /add:<novo-nome>.robson.local

# Etapa 2 — Promove o novo nome a principal (requer reboot)
netdom computername <servidor> /makeprimary:<novo-nome>.robson.local

# Etapa 3 — Remove o nome antigo após o reinício
netdom computername <servidor> /remove:<nome-antigo>.robson.local
```

**Sincronização e limpeza pós-renomeação:**

```powershell
# Força replicação em todas as partições e sites
repadmin /syncall /A /e
```

Após a replicação, os registros DNS antigos (`srv-dc01`, `MBR1`) foram removidos manualmente — registros obsoletos causam falhas de autenticação Kerberos por DNS Round Robin.

**Fix de NTP (problema encontrado em produção):**

`dcdiag` apontou erro 1355 no PDC Emulator após renomeação — o serviço de tempo perdeu referência e parou de distribuir hora para o domínio. Diferenças de tempo superiores a 5 minutos quebram toda a autenticação Kerberos.

```powershell
# Aponta para NTP.br e define como fonte confiável
w32tm /config /manualpeerlist:"a.ntp.br b.ntp.br c.ntp.br,0x8" /syncfromflags:manual /reliable:yes /update

net stop w32time && net start w32time

# Força ressincronização imediata
w32tm /resync
```

| Evidência | Descrição |
|-----------|-----------|
| [![Mudança1](docs/img/Mudança1.png)](docs/img/Mudança1.png) | Execução do `/add` inserindo `CXB-DC01` no AD |
| [![Mudança2](docs/img/Mudança2.png)](docs/img/Mudança2.png) | Execução do `/makeprimary` — alerta de reboot obrigatório |
| [![Mudança3](docs/img/Mudança3.png)](docs/img/Mudança3.png) | Remoção do nome fantasma `SRV-DC01` com `/remove` |
| [![Mudança4](docs/img/Mudança4.png)](docs/img/Mudança4.png) | Mesmo processo no DC secundário removendo `MBR1` |
| [![Mudança5](docs/img/Mudança5.png)](docs/img/Mudança5.png) | `repadmin /syncall` — sincronização concluída sem erros |
| [![Mudança6](docs/img/Mudança6.png)](docs/img/Mudança6.png) | Limpeza no DNS Manager — registros A obsoletos removidos |
| [![Mudança7](docs/img/Mudança7.png)](docs/img/Mudança7.png) | `dcdiag` com erro 1355 no Time Server antes do fix |
| [![Mudança8](docs/img/Mudança8.png)](docs/img/Mudança8.png) | `dcdiag` limpo após reconfiguração do NTP |

---

## 🔐 Fase 2: Segurança, Hardening e Governança (GPO)

---

### 7. Grupos de Segurança — Metodologia AGDLP

Adicionar usuários diretamente nas ACLs de pastas é um antipadrão — cada desligamento vira uma auditoria manual por permissões avulsas espalhadas pelo servidor. A metodologia **AGDLP** resolve isso:

> **A**ccount → **G**lobal Group → **D**omain **L**ocal Group → **P**ermission

- Usuários entram em Grupos Globais por função
- Grupos Globais entram em Grupos de Domínio Local por recurso
- Grupos de Domínio Local recebem permissão na pasta
- Resultado: desligamento = remover da Global Group. Nada mais.

**Implementado:**
- Grupo `G_TI_AcessoFull` (escopo Global) criado para a equipe de TI
- Usuários vinculados ao grupo, não diretamente às pastas

| Evidência | Descrição |
|-----------|-----------|
| [![MembroDe](img/MembroDe.png)](img/MembroDe.png) | Usuário `robson.silva` vinculado ao grupo |
| [![MembroGTI](img/MembroGTI.png)](img/MembroGTI.png) | Configuração do grupo `G_TI_AcessoFull` |

---

### 8. GPO — Bloqueio de Painel de Controle

Usuário final com acesso ao Painel de Controle = chamado aberto por desconfiguração. Essa GPO elimina essa categoria inteira de incidentes.

- **Política:** Bloqueio de Painel de Controle e Configurações do Sistema
- **Escopo:** OU `TI` — homologação antes de expandir para toda a organização
- **Validação:** `gpupdate /force` na estação cliente confirmou a aplicação

| Evidência | Descrição |
|-----------|-----------|
| [![CriandoPoliticaTI](img/CriandoPoliticaTI.png)](img/CriandoPoliticaTI.png) | Criação da GPO no GPMC |
| [![ProibindoAcesso](img/ProibindoAcessoPainelEConf.png)](img/ProibindoAcessoPainelEConf.png) | Configuração da restrição no editor de política |
| [![AbrindoPainel](img/AbrindoPainel.png)](img/AbrindoPainel.png) | Tentativa de acesso pelo usuário |
| [![PainelBloqueado](img/PainelEConfBloq.png)](img/PainelEConfBloq.png) | Bloqueio confirmado na estação |

---

### 9. GPO — Bloqueio de USB (DLP)

Pen drive é vetor duplo de risco: entrada de malware e saída de dados sensíveis. Essa política age no nível de máquina — não importa quem fizer logon.

- **Política:** *All Removable Storage classes: Deny all access*
- **Escopo:** OU `COMPUTADORES` (política de máquina, não de usuário)
- Objeto de computador da estação movido do container padrão para a OU

| Evidência | Descrição |
|-----------|-----------|
| [![USB1](img/USB1.png)](img/USB1.png) | Máquina movida para a OU `COMPUTADORES` |
| [![USB2](img/USB2.png)](img/USB2.png) | Política configurada e ativa no servidor |
| [![USB3](img/USB3.png)](img/USB3.png) | Acesso à unidade removível bloqueado na estação |

---

### 10. Hardening — Protected Users

**Protected Users** é um grupo nativo do AD que aplica proteções adicionais de autenticação às contas membro. Para contas administrativas, é uma das medidas de hardening mais impactantes disponíveis nativamente no Windows Server.

**O que foi implementado:**
- Usuário `Admin-Caxambu` criado na OU `Matriz-Caxambu\ADM`
- Vinculado ao grupo de segurança `GG-Admins-Caxambu`
- Adicionado ao grupo `Protected Users`

**Proteções aplicadas automaticamente:**

| Proteção | Efeito |
|----------|--------|
| ❌ Sem cache NTLM | Elimina ataques Pass-the-Hash |
| ❌ Sem autenticação NTLM / CredSSP / WDigest | Força uso exclusivo de Kerberos |
| ❌ Ticket Kerberos máximo de 4h | Reduz janela de exploração de tickets roubados |
| ❌ Sem delegação Kerberos irrestrita | Bloqueia Unconstrained Delegation attacks |

| Evidência | Descrição |
|-----------|-----------|
| [![P1](img/P1.png)](img/P1.png) | Usuário `Admin-Caxambu` e grupo `GG-Admins-Caxambu` criados |
| [![P2](img/P2.png)](img/P2.png) | Conta adicionada ao grupo `Protected Users` |

---

### 11. Delegação de Privilégios (RBAC) e Segregação de Funções

Em vez de distribuir Domain Admin para a equipe de TI local, delegamos permissões específicas sobre as OUs correspondentes. Menor superfície de ataque, maior rastreabilidade.

**Modelo RBAC aplicado:**
- Grupo `GG-Admins-Caxambu` recebe delegação na OU `Matriz-Caxambu`
- Permissões concedidas: redefinir senhas, desbloquear contas, criar/excluir usuários na OU
- O grupo **não tem** acesso fora da OU delegada — princípio do menor privilégio (PoLP)

| Evidência | Descrição |
|-----------|-----------|
| [![DC1](img/DC1.png)](img/DC1.png) | Wizard de Delegação de Controle na OU `Matriz-Caxambu` |
| [![DC2](img/DC2.png)](img/DC2.png) | Adicionando o grupo `GG-Admins-Caxambu` |
| [![DC3](img/DC3.png)](img/DC3.png) | Seleção das tarefas delegadas |

---

### 12. Atribuição de Direitos — Deny Logon as a Service

> ⚠️ **Evidências sendo adicionadas conforme implementação avança.**

A política **"Deny Logon as a Service"** aplicada a contas administrativas impede que um atacante que comprometa a conta registre um serviço malicioso para manter persistência — técnica comum em ataques pós-exploração (T1543 no MITRE ATT&CK).

---

### 13. Auditoria Avançada de Eventos

> ⚠️ **Evidências sendo adicionadas conforme implementação avança.**

Sem auditoria ativa, qualquer alteração no diretório passa despercebida. Logs avançados ativados para gestão de contas: criação, exclusão, alteração de senha, bloqueio e desbloqueio ficam registrados com usuário executor, horário e estação de origem. Base para qualquer processo de resposta a incidentes.

---

### 14. GPO — Account Lockout e Política de Senhas

> ⚠️ **Evidências sendo adicionadas conforme implementação avança.**

Bloqueio automático após N tentativas inválidas e exigência de complexidade mínima de senha. Duas configurações que eliminam a maior parte dos ataques de força bruta contra o AD com custo zero de implementação.

---

## 📂 Fase 3: Serviços de Arquivos, Storage Avançado e Governança

---

### 15. Servidor de Arquivos e Permissões NTFS

O modelo das "duas portas": o compartilhamento SMB é aberto para o grupo de TI, e o controle granular acontece inteiramente na camada NTFS. O usuário nunca tem mais acesso do que precisa.

**Implementado:**
- Pasta `TI_Confidencial` em `C:\Arquivo_Matriz\`
- Herança de permissões desabilitada por pasta
- Permissão `Modify` para o grupo `G_TI_AcessoFull`

> **Por que `Modify` e não `Full Control`?** Com `Modify`, o usuário lê, escreve e deleta — mas não altera ACLs nem toma posse do objeto. O controle das permissões permanece exclusivo do administrador.

| Evidência | Descrição |
|-----------|-----------|
| [![NTFS1](img/NTFS1.png)](img/NTFS1.png) | Criação de `C:\Arquivo_Matriz\TI_Confidencial` |
| [![NTFS2](img/NTFS2.png)](img/NTFS2.png) | Adicionando `G_TI_AcessoFull` à ACL |
| [![NTFS3](img/NTFS3.png)](img/NTFS3.png) | Permissão `Modify` configurada |
| [![NTFS4](img/NTFS4.png)](img/NTFS4.png) | Herança desabilitada, usuários individuais removidos |
| [![NTFS5](img/NTFS5.png)](img/NTFS5.png) | Unidade de rede mapeada e acessível no WIN10 |
| [![NTFS6](img/NTFS6.png)](img/NTFS6.png) | Validação de acesso por grupo — acesso permitido e registrado |

---

### 🖥️ CXB-FS01 — Storage Spaces: Arquitetura Base do Servidor de Arquivos

> **[→ Documentação técnica completa em `docs/fase3-storage-governança/`](docs/fase3-storage-governança/fase3-storage-governança.md)**

O `CXB-FS01` é a VM dedicada para todos os serviços de arquivo. Em vez de uma partição simples, foi construído sobre **Storage Spaces** — a camada de abstração de armazenamento do Windows Server — permitindo expansão futura de capacidade sem downtime e provisionamento inteligente de espaço.

#### Topologia do Lab — 4 Nós

| Evidência | Descrição |
|-----------|-----------|
| [![Storage 1](docs/fase3-storage-governança/img/1.png)](docs/fase3-storage-governança/img/1.png) | Hyper-V com os 4 nós: `CXB-DC01`, `CXB-DC02`, `CXB-FS01` e `WIN10` |

#### Provisionamento Físico — 3 Discos VHDX de 20GB

Foram adicionados 3 discos virtuais VHDX à controladora SCSI do `CXB-FS01`. Expansão dinâmica no host para otimização de recursos.

| Evidência | Descrição |
|-----------|-----------|
| [![Storage 2](docs/fase3-storage-governança/img/2.png)](docs/fase3-storage-governança/img/2.png) | 3 discos RAW de 20GB adicionados ao servidor |

#### Storage Pool — `POOL-DADOS-CXB`

Os 3 discos RAW foram unificados em um único Pool Lógico `POOL-DADOS-CXB`. Isso abstrai o hardware físico — o administrador gerencia um recurso único de 60GB. Expansão futura = adicionar disco ao pool, sem reformatar.

| Evidência | Descrição |
|-----------|-----------|
| [![Storage 3](docs/fase3-storage-governança/img/3.png)](docs/fase3-storage-governança/img/3.png) | Criação do `POOL-DADOS-CXB` unificando os 3 discos |

#### Storage Tiering — Conceito Documentado

A opção Storage Tiers aparece desabilitada no lab (todos os discos são do mesmo tipo virtual).

> **Em produção:** o Tiering mescla SSDs (camada rápida) e HDDs (camada de capacidade). O Windows move automaticamente *Hot Data* para SSDs e *Cold Data* para HDDs — otimizando custo e performance sem intervenção manual.

| Evidência | Descrição |
|-----------|-----------|
| [![Storage 4](docs/fase3-storage-governança/img/4.png)](docs/fase3-storage-governança/img/4.png) | Storage Tiers indisponível com discos homogêneos |

#### Layout — Simple (Striping)

Foi escolhido o layout **Simple (Striping)** em vez de Mirror.

> **Justificativa:** discos virtuais residem no mesmo SSD físico do host — Mirror geraria overhead sem ganho real de redundância. Simple soma os 60GB e maximiza throughput de I/O. **Em produção com hardware real, a escolha seria Mirror ou Parity.**

| Evidência | Descrição |
|-----------|-----------|
| [![Storage 5](docs/fase3-storage-governança/img/5.png)](docs/fase3-storage-governança/img/5.png) | Layout Simple (Striping) selecionado |

#### Thin Provisioning e Overprovisioning

**Thin (Dinâmico):** espaço alocado no disco físico somente conforme os dados são gravados. Permite configurar o disco virtual maior que o pool físico atual.

> **Overprovisioning:** amplamente usado por AWS, Azure e outros. Apresenta um disco grande ao SO, adiando a compra de hardware adicional até que o uso real se aproxime do limite físico.
>
> **Write-back Cache:** espaço reservado para absorver picos de gravação usando a camada mais rápida, evitando lentidão percebida pelo usuário.

| Evidência | Descrição |
|-----------|-----------|
| [![Storage 6](docs/fase3-storage-governança/img/6.png)](docs/fase3-storage-governança/img/6.png) | Thin provisioning e Overprovisioning configurados |

#### SMB Multichannel — Validação

`Get-SmbServerConfiguration` confirmou o SMB Multichannel ativo nativamente no `CXB-FS01`.

> **Benefícios:**
> - **Agregação de Banda:** 2 NICs de 1Gbps = 2Gbps efetivos de throughput
> - **Tolerância a Falhas de Rede:** cabo rompido → transferência continua pela outra NIC sem interrupção para o usuário

| Evidência | Descrição |
|-----------|-----------|
| [![Storage 7](docs/fase3-storage-governança/img/7.png)](docs/fase3-storage-governança/img/7.png) | `Get-SmbServerConfiguration` — Multichannel ativo |

#### Volume Final — `E: Dados-CXB` em NTFS

| Evidência | Descrição |
|-----------|-----------|
| [![Storage 8](docs/fase3-storage-governança/img/8.png)](docs/fase3-storage-governança/img/8.png) | Volume `E: Dados-CXB` montado e formatado em NTFS |
| [![Storage 9](docs/fase3-storage-governança/img/9.png)](docs/fase3-storage-governança/img/9.png) | Validação final no Server Manager |

> **Por NTFS e não ReFS?** NTFS é pré-requisito obrigatório para as roles de governança. ReFS não suporta FSRM; FAT32 não suporta ACLs granulares nem Data Deduplication.

---

### Estrutura de Dados e Otimização — Data Dedup e DFS-N

> ⚠️ **Em documentação — [ver `docs/fase3-storage-governança/`](docs/fase3-storage-governança/fase3-storage-governança.md)**

**Data Deduplication:** elimina blocos duplicados no volume NTFS, reduzindo consumo de espaço por arquivos similares. Em ambientes corporativos pode reduzir o uso de storage em 30–70%.

**DFS Namespaces (DFS-N):** cria um caminho UNC único (`\\robson.local\dados`) que abstrai o servidor real por baixo. Migrações de servidor ficam transparentes para o usuário.

---

### Governança e Segurança — FSRM, NTFS e ABE

> ⚠️ **Em documentação — [ver `docs/fase3-storage-governança/`](docs/fase3-storage-governança/fase3-storage-governança.md)**

**FSRM (File Server Resource Manager):**
- Quotas por usuário/pasta — impede um departamento de monopolizar o storage
- File Screening — bloqueia extensões proibidas (`.mp3`, `.avi`, `.exe`) de serem salvas no servidor
- Relatórios de uso agendados com envio automático por e-mail

**ABE (Access-Based Enumeration):**
- Usuários enxergam somente as pastas às quais têm acesso NTFS
- Pastas de outros departamentos ficam invisíveis — reduz vetores de reconhecimento interno e evita curiosidade sobre recursos não autorizados

---

### 16. Mapeamento Automático de Unidades via GPO

> ⚠️ **Em documentação.**

GPO com Drive Maps faz o mapeamento automaticamente no logon do usuário, com **Item-Level Targeting** por departamento: usuários de TI recebem `T:`, usuários de ADM recebem `A:`. Sem script local, sem intervenção manual, sem suporte.

---

### Conectividade Matriz/Filial

> ⚠️ **Em documentação — [ver `docs/fase3-conectividade-filial/`](docs/fase3-conectividade-filial/fase3-conectividade-filial.md)**

DFS-R para replicação de arquivos entre sites, VPN site-to-site e BranchCache para otimização de acesso a conteúdo do servidor centralizado via link WAN.

---

### Gestão e Disaster Recovery

> ⚠️ **Em documentação — [ver `docs/fase3-disaster-recovery/`](docs/fase3-disaster-recovery/fase3-disaster-recovery.md)**

Windows Admin Center (WAC) como painel centralizado, VSS para snapshots consistentes de dados em uso e estratégia de backup otimizado para o ambiente multi-DC e multi-site.

---

## ☁️ Próximos Passos

- [x] Estrutura de OUs e grupos de segurança (AGDLP)
- [x] Automação de onboarding via PowerShell + CSV
- [x] Alta disponibilidade — DC Secundário (`CXB-DC02`)
- [x] Design Multi-Site e controle de replicação
- [x] Gestão e redistribuição de Roles FSMO
- [x] Troubleshooting: renomeação de DCs + replicação + fix de NTP
- [x] GPOs de hardening (Painel de Controle e USB/DLP)
- [x] Servidor de Arquivos com permissões NTFS granulares
- [x] Delegação de Privilégios (RBAC) e Segregação de Funções
- [x] Hardening — Protected Users (eliminação de NTLM / Pass-the-Hash)
- [x] `CXB-FS01` — Storage Spaces com Thin Provisioning e SMB Multichannel
- [ ] Data Deduplication e DFS Namespaces (DFS-N)
- [ ] FSRM — Quotas, File Screening e relatórios agendados
- [ ] ABE (Access-Based Enumeration) no File Server
- [ ] Auditoria avançada de eventos de diretório
- [ ] Account Lockout Policy e política de complexidade de senhas
- [ ] Mapeamento automático de unidades via GPO (Item-Level Targeting)
- [ ] Print Server e distribuição de impressoras via GPO
- [ ] Conectividade Matriz/Filial — DFS-R, VPN site-to-site e BranchCache
- [ ] Disaster Recovery — WAC, VSS e Backup otimizado
- [ ] Segregação física de rede no Hyper-V (roteamento RRAS entre `10.x` e `172.x`)
- [ ] Sincronização com Azure AD / Microsoft Entra ID (Hybrid Identity)
- [ ] PowerShell IaC — automação completa do provisionamento do lab

---

<p align="center">
  <sub>Documentação viva — atualizada conforme o lab evolui.</sub>
</p>