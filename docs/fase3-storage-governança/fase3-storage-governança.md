# Fase 3: Storage Avançado e Governança de Dados

## 1. Arquitetura Base de Armazenamento (Storage Spaces)

# Fase 1: Arquitetura Base de Armazenamento (Storage Spaces)

Nesta primeira fase, preparamos a fundação do nosso Servidor de Arquivos (`CXB-FS01`). Em vez de utilizar partições simples e engessadas, a arquitetura foi desenhada utilizando **Storage Spaces**, permitindo provisionamento inteligente, expansão futura e alta performance de rede.

Abaixo, detalho o processo de criação e as decisões arquiteturais tomadas durante o provisionamento.

---

### 1. Topologia do Laboratório
<img src="img/1.png" width="800">

> **Visão do Hyper-V com os nós da infraestrutura (`CXB-DC01`, `DC02`, `FS01` e `WIN10`).** O servidor de arquivos foi isolado em uma VM dedicada para centralizar as roles de File Services.

---

### 2. Provisionamento Físico (Discos Virtuais)
<img src="img/2.png" width="800">

> Foram adicionados 3 discos virtuais (VHDX) de 20GB cada à controladora SCSI do servidor. Optou-se por expansão dinâmica no host físico para otimização de recursos do laboratório.

---

### 3. Criação do Storage Pool
<img src="img/3.png" width="800">

> Os 3 discos "crus" (RAW) foram unificados em um único Pool Lógico (`POOL-DADOS-CXB`). Isso abstrai o hardware físico, permitindo gerenciar o armazenamento como um único recurso flexível.

---

### 4. Nomeação e Conceito de Storage Tiering
<img src="img/4.png" width="800">

> A opção **Storage Tiers** aparece desabilitada pois todos os discos virtuais são do mesmo tipo. 
> * **Conceito Aplicado:** Em um ambiente de produção real, o Tiering mescla SSDs (Camada Rápida) e HDDs (Camada Capacidade). O Windows move automaticamente os arquivos mais acessados (Hot Data) para os SSDs e os arquivos antigos (Cold Data) para os HDDs, otimizando custo e performance.

---

### 5. Layout de Armazenamento (Simple)
<img src="img/5.png" width="800">

> Foi escolhido o layout **Simple** (Striping). 
> * **Justificativa:** Como os discos virtuais já residem no mesmo SSD físico do host, usar *Mirror* (Espelhamento) geraria overhead sem ganho real de redundância. O *Simple* soma a capacidade total (60GB) e maximiza a performance de I/O para os testes. Em produção (hardware físico), a escolha seria *Mirror* ou *Parity* para tolerância a falhas.

---

### 6. Tipo de Provisionamento (Thin)
<img src="img/6.png" width="800">

> Configurado como **Thin (Dinâmico)**. 
> * **Justificativa:** O espaço só é alocado no disco físico conforme os usuários efetivamente gravam dados. Isso otimiza o uso do storage do Datacenter, evitando desperdício de espaço alocado e não utilizado (comum no provisionamento *Fixed*).

---

### 7. Overprovisioning e Write-back Cache
<img src="img/7.png" width="800">

> Devido ao provisionamento Thin, é possível configurar o Disco Virtual com um tamanho maior que o Pool físico atual.
> * **Overprovisioning:** Técnica amplamente usada por provedores de nuvem como a AWS. Permite apresentar um disco enorme ao SO e adiar a compra de gavetas de discos físicos até que o limite real se aproxime. 
> * **Write-back Cache:** A interface reserva espaço para o cache, que usa a camada rápida para absorver picos de gravação repentinos, evitando lentidão para o usuário final.

---

### 8. Validação do SMB Multichannel
<img src="img/8.png" width="800">

> Validação via PowerShell (`Get-SmbServerConfiguration`). O recurso ativo nativamente traz dois grandes benefícios: 
> 1. **Agregação de Banda:** Se o servidor tiver 2 ou mais placas de rede de 1Gbps, ele soma a velocidade (2Gbps) para transferência de arquivos. 
> 2. **Tolerância a Falhas:** Se um cabo de rede for rompido, a transferência continua pelo outro sem que a cópia do usuário seja interrompida.

---

### 9. Resultado Final (Volume E:)
<img src="img/9.png" width="800">

> O volume `Dados-CXB` foi formatado em **NTFS** e montado com sucesso. A escolha do NTFS é um pré-requisito arquitetural obrigatório para a implementação das roles de Governança (FSRM) e Desduplicação na próxima fase.

## 2. Estrutura de Dados e Otimização (Dedup e DFS-N)

Nesta segunda fase, transformamos o storage bruto da Fase 1 em um serviço de arquivos inteligente. O objetivo foi maximizar a eficiência do disco e criar uma camada de abstração que permite que a infraestrutura cresça sem impactar a experiência do usuário final.

---

### 2.1. Instalação de Roles e Recursos Críticos
<img src="img/10.png" width="800">

> **Provisionamento de Roles:** Instalação das funcionalidades de **Data Deduplication**, **DFS Namespaces**, **DFS Replication** (preparando para a filial BH) e o **File Server Resource Manager (FSRM)**. Essa stack compõe o núcleo de um servidor de arquivos corporativo moderno.

---

### 2.2. Otimização de Storage: Data Deduplication
<img src="img/11.png" width="800">

> **Seleção do Volume Alvo:** A desduplicação foi aplicada exclusivamente no volume **E: (Dados-CXB)**. Ao isolar os dados do sistema operacional (C:), garantimos que o processo de otimização não gere overhead no kernel do Windows.

<img src="img/12.png" width="800">

> **Agendamento Inteligente (Deduplication Schedule):**
> * **Background Optimization:** Ativada para processamento contínuo em baixa prioridade.
> * **Throughput Optimization:** Configurada para as **02:00 AM** com duração de 6 horas. 
> * **Justificativa:** Esta "faxina pesada" ocorre na janela de menor uso da rede (madrugada), garantindo que a CPU do servidor esteja 100% disponível para os usuários durante o horário comercial.

---

### 2.3. Abstração de Rede: DFS Namespaces (DFS-N)
<img src="img/13.png" width="800">

> O **Distributed File System (DFS)** foi implementado para criar um caminho universal, escondendo a complexidade do hardware físico atrás de um nome lógico baseado no domínio.

<img src="img/15.png" width="800">

> **Decisão Arquitetural Crítica (Edit Settings):** Durante a criação do Namespace, o caminho padrão sugerido pelo Windows (`C:\DFSRoots`) foi alterado manualmente para **`E:\Arquivos`**.
> * **Por que isso é importante?** Se mantivéssemos no disco C:, ignoraríamos todo o Storage Pool e a Desduplicação configurada. Ao apontar para o disco E:, forçamos o tráfego de dados para a camada de armazenamento otimizada e segura.
> * **Permissões de Share:** Definidas como *Administrators Full / Users Read-Write*, delegando o controle restritivo para a camada NTFS (Fase 3).

<img src="img/16.png" width="800">

> **Namespace Baseado em Domínio:** Foi selecionado o modo de domínio (`\\robson.local\Arquivos`). Isso permite que, no futuro, se o servidor físico `CXB-FS01` for substituído ou se adicionarmos um servidor em Belo Horizonte, o usuário continue acessando o mesmo caminho, sem nunca precisar remapear unidades de rede.

---

### 2.4. Validação do Caminho Universal
<img src="img/18.png" width="800">

> **Resultado Final:** O Namespace está ativo e saudável. Agora, qualquer dispositivo no domínio `robson.local` acessa a estrutura centralizada através de um único ponto de entrada, independentemente de onde os dados estejam fisicamente armazenados.

## 3. Governança e Segurança (FSRM, NTFS e ABE)
