#  Fase 3: Storage Avançado e Governança de Dados

Esta fase detalha a transformação do servidor `CXB-FS01` numa solução de armazenamento de classe empresarial, focada em alta disponibilidade, eficiência de espaço e segurança proativa.

---

## 1. Arquitetura Base de Armazenamento (Storage Spaces)

Nesta primeira fase, preparámos a fundação do nosso Servidor de Ficheiros. Em vez de utilizar partições simples e rígidas, a arquitetura foi desenhada utilizando **Storage Spaces**, permitindo aprovisionamento inteligente, expansão futura e alta performance de rede.

### 1.1. Topologia e Aprovisionamento Físico
| Evidência | Descrição |
|-----------|-----------|
| [![Storage 1](img/1.png)](img/1.png) | **Topologia do Laboratório:** Visão do Hyper-V com os nós da infraestrutura (`CXB-DC01`, `DC02`, `FS01` e `WIN10`). O servidor de ficheiros foi isolado numa VM dedicada. |
| [![Storage 2](img/2.png)](img/2.png) | **Aprovisionamento Físico:** Adição de 3 discos virtuais (VHDX) de 20GB cada à controladora SCSI do servidor. |

### 1.2. Criação do Storage Pool e Layout
| Evidência | Descrição |
|-----------|-----------|
| [![Storage 3](img/3.png)](img/3.png) | **Storage Pool:** Unificação dos 3 discos no `POOL-DADOS-CXB`. Isto abstrai o hardware físico, permitindo gerir o armazenamento como um recurso único e flexível. |
| [![Storage 4](img/4.png)](img/4.png) | **Conceito de Storage Tiering:** Explicação do uso de SSDs (Hot Data) e HDDs (Cold Data) para otimização de custo e performance em ambientes de produção. |
| [![Storage 5](img/5.png)](img/5.png) | **Layout de Armazenamento (Simple):** Escolhido para maximizar a performance de I/O e aproveitar a capacidade total (60GB) no ambiente de laboratório. |

### 1.3. Otimização e Entrega do Volume
| Evidência | Descrição |
|-----------|-----------|
| [![Storage 6](img/6.png)](img/6.png) | **Tipo de Aprovisionamento (Thin):** Configuração dinâmica onde o espaço só é alocado conforme o uso, permitindo técnicas de *Overprovisioning*. |
| [![Storage 7](img/7.png)](img/7.png) | **Validação do SMB Multichannel:** Validação via PowerShell. Recurso que permite agregação de banda e tolerância a falhas em servidores com múltiplas interfaces de rede. |
| [![Storage 8](img/8.png)](img/8.png) | **Resultado Final (Volume E:):** Volume formatado em NTFS, requisito obrigatório para as roles de Governança (FSRM) e Desduplicação. |

---

## 2. Estrutura de Dados e Otimização (Dedup e DFS-N)

Nesta segunda fase, transformámos o storage bruto num serviço de ficheiros inteligente, maximizando a eficiência do disco e criando uma camada de abstração de rede.

### 2.1. Instalação de Roles e Data Deduplication
| Evidência | Descrição |
|-----------|-----------|
| [![Storage 10](img/10.png)](img/10.png) | **Aprovisionamento de Roles:** Instalação de Data Deduplication, DFS Namespaces, DFS Replication e FSRM. |
| [![Storage 11](img/11.png)](img/11.png) | **Seleção do Volume Alvo:** Aplicação da desduplicação exclusivamente no volume **E: (Dados-CXB)** para evitar overhead no disco do sistema operativo. |
| [![Storage 12](img/12.png)](img/12.png) | **Agendamento Inteligente:** Configuração da "limpeza pesada" para as 02:00 AM, garantindo que a CPU esteja 100% disponível para os utilizadores durante o dia. |

### 2.2. Abstração de Rede via DFS Namespaces (DFS-N)
| Evidência | Descrição |
|-----------|-----------|
| [![Storage 13](img/13.png)](img/13.png) | **Implementação do DFS-N:** Criação do caminho universal `\\robson.local\Arquivos`. |
| [![Storage 15](img/15.png)](img/15.png) | **Decisão Arquitetural (Edit Settings):** Alteração manual do caminho de `C:\DFSRoots` para `E:\Arquivos` para utilizar o Storage Pool otimizado. |
| [![Storage 16](img/16.png)](img/16.png) | **Namespace de Domínio:** Configuração que garante que a migração de servidores físicos seja transparente para o utilizador final. |
| [![Storage 18](img/18.png)](img/18.png) | **Validação:** Ponto de entrada universal ativo e saudável. |

---

## 3. Governança e Segurança (FSRM, NTFS e ABE)

Nesta fase, implementamos a "blindagem" do servidor. O foco saiu da infraestrutura bruta para a proteção lógica e governança, garantindo que os dados estejam disponíveis apenas para quem possui permissão e protegidos contra ameaças externas e uso indevido de espaço.

---

### 3.1. Estrutura Departamental e Permissões NTFS
<img src="img/19.png" width="800">

> **Segregação de Dados:** A estrutura física no disco `E:` foi criada para espelhar as Unidades Organizacionais (UOs) do Active Directory. Criamos os diretórios `ADM`, `TI` e `Publico`.

<img src="img/20.png" width="800">

> **Quebra de Herança (Princípio do Menor Privilégio):** > * **Ação:** Foi desabilitada a herança de permissões vinda da raiz do disco. 
> * **Justificativa:** Em um ambiente corporativo, pastas departamentais não devem herdar permissões genéricas. Ao quebrar a herança, removemos os grupos `Users` e `Authenticated Users`, garantindo que o acesso seja negado por padrão (*Implicit Deny*).

<img src="img/21.png" width="800">
<img src="img/22.png" width="800">

> **Aplicação do Modelo AGDLP:** As permissões foram concedidas estritamente a **Grupos Globais de Segurança**. No exemplo da pasta `ADM`, o acesso de **Modificação (Modify)** foi atribuído ao grupo `GG-Admins-Caxambu`. 
> * *Nota:* Mantivemos os grupos `SYSTEM` e `Administrators` para garantir a continuidade de rotinas de backup e manutenção.

---

### 3.2. Access-Based Enumeration (ABE) - Invisibilidade Seletiva
<img src="img/23-ABE.png" width="800">

> **Configuração de UX e Segurança:** Habilitamos o **ABE** nas propriedades do Namespace DFS.
> * **O que isso faz?** Se um usuário da TI acessar o caminho `\\robson.local\Arquivos`, a pasta `ADM` sequer aparecerá para ele. Isso reduz a curiosidade interna e evita chamados desnecessários ao suporte por "Acesso Negado", pois o usuário só enxerga o que pode abrir.

---

### 3.3. Gestão de Cotas (FSRM Quotas)
<img src="img/24.png" width="800">

> **Controle de Crescimento:** Implementação de **Hard Quotas** de 10GB na pasta `ADM`.
> * **Decisão Sênior:** Utilizamos a opção *"Derive properties from this quota template"*. Isso permite que, se no futuro precisarmos aumentar o espaço de todos os departamentos para 20GB, alteramos apenas o template central e a mudança será replicada automaticamente para todas as pastas vinculadas, garantindo escalabilidade na gestão.

---

### 3.4. Blindagem Anti-Ransomware e Triagem de Arquivos
<img src="img/25.png" width="800">

> **Criação de Dicionário de Ameaças (File Groups):** Criamos o grupo customizado `[SecOps] Bloqueio de Executáveis e Ransomware`. Foram incluídas extensões críticas como `.exe` (bloqueio de Shadow IT), `.bat`, `.ps1` (scripts maliciosos) e assinaturas de ransomware como `.crypt`, `.locky` e `.wannacry`.

<img src="img/26.png" width="800">

> **Template de Segurança Máxima:** Unificamos o bloqueio de arquivos multimídia (para economizar storage) com o bloqueio de executáveis/ransomware em um único template de **Triagem Ativa (Active Screening)**.

<img src="img/27.png" width="800">

> **Auditoria e Alerta (Event Log):** Configuramos a política para que toda tentativa de violação (ex: usuário tentando salvar um vírus ou um filme) gere um aviso no **Windows Event Log**. Isso permite monitoramento proativo via ferramentas de SIEM ou análise manual da TI.

<img src="img/28.png" width="800">

> **Aplicação na Raiz (Cascata):** A regra final foi aplicada na raiz `E:\Arquivos`. Por herança do FSRM, todas as subpastas atuais e futuras estarão automaticamente protegidas por essa política, garantindo que nenhum "ponto cego" de segurança exista no servidor.