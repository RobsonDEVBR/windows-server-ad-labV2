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

Nesta fase, implementámos a "blindagem" do servidor, garantindo proteção lógica, controlo de acesso granular e defesa contra Ransomware.

### 3.1. Estrutura Departamental e Permissões NTFS
| Evidência | Descrição |
|-----------|-----------|
| [![Storage 19](img/19.png)](img/19.png) | **Segregação de Dados:** Criação dos diretórios `ADM`, `TI` e `Publico` espelhando as OUs do Active Directory. |
| [![Storage 20](img/20.png)](img/20.png) | **Hardening (Quebra de Herança):** Desativação da herança para garantir que cada pasta departamental tenha a sua própria ACL isolada (*Implicit Deny*). |
| [![Storage 21](img/21.png)](img/21.png) | **Limpeza de ACL:** Remoção de grupos genéricos (`Users`), mantendo apenas acessos explícitos, `SYSTEM` e `Administrators`. |
| [![Storage 22](img/22.png)](img/22.png) | **Metodologia AGDLP:** Atribuição de acesso `Modify` ao grupo global `GG-Admins-Caxambu` na pasta correspondente. |

### 3.2. ABE e Gestão de Cotas
| Evidência | Descrição |
|-----------|-----------|
| [![Storage ABE](img/23-ABE.png)](img/23-ABE.png) | **Access-Based Enumeration (ABE):** Configuração para que pastas às quais o utilizador não tem acesso NTFS fiquem invisíveis na rede. |
| [![Storage 24](img/24.png)](img/24.png) | **Gestão de Cotas:** Implementação de *Hard Quotas* de 10GB via Template, garantindo escalabilidade na administração do espaço. |

### 3.3. Blindagem Anti-Ransomware e Triagem Ativa
| Evidência | Descrição |
|-----------|-----------|
| [![Storage 25](img/25.png)](img/25.png) | **Dicionário de Ameaças:** Criação do grupo `[SecOps]` bloqueando `.exe` (Shadow IT) e extensões de Ransomware (`.crypt`, `.locky`, `.wannacry`). |
| [![Storage 26](img/26.png)](img/26.png) | **Template de Segurança Máxima:** Unificação do bloqueio de média e executáveis maliciosos num modelo de **Active Screening**. |
| [![Storage 27](img/27.png)](img/27.png) | **Auditoria (Event Log):** Configuração de alertas automáticos no log do Windows para cada tentativa de violação de política. |
| [![Storage 28](img/28.png)](img/28.png) | **Configuração de Triagem:** Detalhes da política de bloqueio impeditivo. |
| [![Storage 29](img/29.png)](img/29.png) | **Proteção em Cascata:** Aplicação da triagem na raiz `E:\Arquivos`, protegendo todo o sistema de ficheiros de forma hereditária. |

---
> **Nota Técnica:** Implementámos uma **Exceção de Triagem** na subpasta `TI`, permitindo que o grupo de tecnologia armazene scripts `.ps1` necessários para automação, mantendo o bloqueio ativo para o restante da empresa.