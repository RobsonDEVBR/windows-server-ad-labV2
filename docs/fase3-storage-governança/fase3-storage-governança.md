#  Fase 3: Storage Avançado e Governança de Dados

Esta fase detalha a transformação do servidor `CXB-FS01` numa solução de armazenamento de classe empresarial, focada em alta disponibilidade, eficiência de espaço e segurança proativa.

---

## 1. Arquitetura Base de Armazenamento (Storage Spaces)

Nesta primeira fase, preparámos a fundação do nosso Servidor de Ficheiros. Em vez de utilizar partições simples e rígidas, a arquitetura foi desenhada utilizando **Storage Spaces**, permitindo aprovisionamento inteligente, expansão futura e alta performance de rede.

### 1.1. Topologia e Aprovisionamento Físico
| Evidência | Descrição |
|-----------|-----------|
| <img src="img/1.png" width="1000"> | **Topologia do Laboratório:**<br>Visão do Hyper-V com os nós da infraestrutura (`CXB-DC01`, `DC02`, `FS01` e `WIN10`).<br><br>O servidor de ficheiros foi isolado numa VM dedicada. |
| <img src="img/2.png" width="1000"> | **Aprovisionamento Físico:**<br>Adição de 3 discos virtuais (VHDX) de 20GB cada à controladora SCSI do servidor. |

### 1.2. Criação do Storage Pool e Layout
| Evidência | Descrição |
|-----------|-----------|
| <img src="img/3.png" width="1000"> | **Storage Pool:**<br>Unificação dos 3 discos no `POOL-DADOS-CXB`.<br><br>Isto abstrai o hardware físico, permitindo gerir o armazenamento como um recurso único e flexível. |
| <img src="img/4.png" width="1000"> | **Conceito de Storage Tiering:**<br>Explicação do uso de SSDs (Hot Data) e HDDs (Cold Data) para otimização de custo e performance em ambientes de produção. |
| <img src="img/5.png" width="1000"> | **Layout de Armazenamento (Simple):**<br>Escolhido para maximizar a performance de I/O e aproveitar a capacidade total (60GB) no ambiente de laboratório. |

### 1.3. Otimização e Entrega do Volume
| Evidência | Descrição |
|-----------|-----------|
| <img src="img/6.png" width="1000"> | **Tipo de Aprovisionamento (Thin):**<br>Configuração dinâmica onde o espaço só é alocado conforme o uso, permitindo técnicas de *Overprovisioning*. |
| <img src="img/8.png" width="1000"> | **Validação do SMB Multichannel:**<br>Validação via PowerShell.<br><br>Recurso que permite agregação de banda e tolerância a falhas em servidores com múltiplas interfaces de rede. |
| <img src="img/9.png" width="1000"> | **Resultado Final (Volume E:):**<br>Volume formatado em NTFS, requisito obrigatório para as roles de Governança (FSRM) e Desduplicação. |

---

## 2. Estrutura de Dados e Otimização (Dedup e DFS-N)

Nesta segunda fase, transformámos o storage bruto num serviço de ficheiros inteligente, maximizando a eficiência do disco e criando uma camada de abstração de rede.

### 2.1. Instalação de Roles e Data Deduplication
| Evidência | Descrição |
|-----------|-----------|
| <img src="img/10.png" width="1000"> | **Aprovisionamento de Roles:**<br>Instalação de Data Deduplication, DFS Namespaces, DFS Replication e FSRM. |
| <img src="img/11.png" width="1000"> | **Seleção do Volume Alvo:**<br>Aplicação da desduplicação exclusivamente no volume **E: (Dados-CXB)** para evitar overhead no disco do sistema operativo. |
| <img src="img/12.png" width="1000"> | **Agendamento Inteligente:**<br>Configuração da "limpeza pesada" para as 02:00 AM, garantindo que a CPU esteja 100% disponível para os utilizadores durante o dia. |

### 2.2. Abstração de Rede via DFS Namespaces (DFS-N)
| Evidência | Descrição |
|-----------|-----------|
| <img src="img/13.png" width="1000"> | **Implementação do DFS-N:**<br>Criação do caminho universal `\\robson.local\Arquivos`. |
| <img src="img/15.png" width="1000"> | **Decisão Arquitetural (Edit Settings):**<br>Alteração manual do caminho de `C:\DFSRoots` para `E:\Arquivos` para utilizar o Storage Pool otimizado. |
| <img src="img/16.png" width="1000"> | **Namespace de Domínio:**<br>Configuração que garante que a migração de servidores físicos seja transparente para o utilizador final. |
| <img src="img/18.png" width="1000"> | **Validação:**<br>Ponto de entrada universal ativo e saudável. |

---

## 3. Governança e Segurança (FSRM, NTFS e ABE)

Nesta fase, implementamos a "blindagem" do servidor. O foco saiu da infraestrutura bruta para a proteção lógica e governança, garantindo que os dados estejam disponíveis apenas para quem possui permissão e protegidos contra ameaças externas e uso indevido de espaço.

---

### 3.1. Estrutura Departamental e Permissões NTFS

Nesta etapa, aplicamos o princípio do privilégio mínimo, garantindo que o acesso aos dados seja controlado por grupos de segurança e não por usuários individuais.

| Evidência | Descrição |
|-----------|-----------|
| <img src="img/19.png" width="1000"> | **Segregação de Dados:**<br>A estrutura física no disco `E:` foi criada para espelhar as Unidades Organizacionais (UOs) do Active Directory.<br><br>Criamos os diretórios `ADM`, `TI` e `Publico`. |
| <img src="img/20.png" width="1000"> | **Quebra de Herança (Princípio do Menor Privilégio):**<br>Foi desabilitada a herança de permissões vinda da raiz do disco.<br><br>Em um ambiente corporativo, pastas departamentais não devem herdar permissões genéricas. Ao quebrar a herança, removemos os grupos `Users` e `Authenticated Users`, garantindo que o acesso seja negado por padrão (*Implicit Deny*). |
| <img src="img/21.png" width="1000"> | **Limpeza de ACL:**<br>Mantivemos os grupos `SYSTEM` e `Administrators` para garantir a continuidade de rotinas de backup e manutenção. |
| <img src="img/22.png" width="1000"> | **Aplicação do Modelo AGDLP:**<br>As permissões foram concedidas estritamente a **Grupos Globais de Segurança**.<br><br>No exemplo da pasta `ADM`, o acesso de **Modificação (Modify)** foi atribuído ao grupo `GG-Admins-Caxambu`. |

---

### 3.2. Access-Based Enumeration (ABE) - Invisibilidade Seletiva

| Evidência | Descrição |
|-----------|-----------|
| <img src="img/23-ABE.png" width="1000"> | **Configuração de UX e Segurança:**<br>Habilitamos o **ABE** nas propriedades do Namespace DFS.<br><br>Se um usuário da TI acessar o caminho `\\robson.local\Arquivos`, a pasta `ADM` sequer aparecerá para ele. Isso reduz a curiosidade interna e evita chamados desnecessários ao suporte por "Acesso Negado", pois o usuário só enxerga o que pode abrir. |

---

### 3.3. Gestão de Cotas (FSRM Quotas)

| Evidência | Descrição |
|-----------|-----------|
| <img src="img/24.png" width="1000"> | **Controle de Crescimento:**<br>Implementação de **Hard Quotas** de 10GB na pasta `ADM`.<br><br>Utilizamos a opção *"Derive properties from this quota template"*. Isso permite que, se no futuro precisarmos aumentar o espaço de todos os departamentos para 20GB, alteramos apenas o template central e a mudança será replicada automaticamente para todas as pastas vinculadas, garantindo escalabilidade na gestão. |

---

### 3.4. Blindagem Anti-Ransomware e Triagem de Arquivos

| Evidência | Descrição |
|-----------|-----------|
| <img src="img/25.png" width="1000"> | **Criação de Dicionário de Ameaças (File Groups):**<br>Criamos o grupo customizado `[SecOps] Bloqueio de Executáveis e Ransomware`.<br><br>Foram incluídas extensões críticas como `.exe` (bloqueio de Shadow IT), `.bat`, `.ps1` (scripts maliciosos) e assinaturas de ransomware como `.crypt`, `.locky` e `.wannacry`. |
| <img src="img/26.png" width="1000"> | **Template de Segurança Máxima:**<br>Unificamos o bloqueio de arquivos multimídia (para economizar storage) com o bloqueio de executáveis/ransomware em um único template de **Triagem Ativa (Active Screening)**. |
| <img src="img/27.png" width="1000"> | **Auditoria e Alerta (Event Log):**<br>Configuramos a política para que toda tentativa de violação (ex: usuário tentando salvar um vírus ou um filme) gere um aviso no **Windows Event Log**.<br><br>Isso permite monitoramento proativo via ferramentas de SIEM ou análise manual da TI. |
| <img src="img/28.png" width="1000"> | **Configuração de Triagem:**<br>Detalhes da política de bloqueio impeditivo configurada no File System. |
| <img src="img/29.png" width="1000"> | **Aplicação em Cascata (Root Protection):**<br>A política de triagem foi aplicada na raiz `E:\Arquivos`. Com isso, todas as subpastas atuais e futuras herdam automaticamente a proteção.<br><br>O servidor torna-se uma "fortaleza" onde o sistema de arquivos atua como a primeira linha de defesa contra ataques de criptografia de dados. |

> **Destaque de Portfólio:** A combinação de **NTFS (Segurança)**, **ABE (Invisibilidade)** e **FSRM (Prevenção)** transforma o servidor em uma "fortaleza de dados", operando sob o modelo de confiança zero (*Zero Trust*) para extensões de arquivos e acesso a diretórios.