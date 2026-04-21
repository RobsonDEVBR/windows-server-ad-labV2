# Fase 3: Storage Avançado e Governança de Dados

# 1. Arquitetura Base de Armazenamento (Storage Spaces)

Essa foi a parte onde eu montei a fundação do servidor de arquivos (`CXB-FS01`). Em vez de sair criando partição C, D, E do jeito antigo, resolvi usar **Storage Spaces** desde o começo. A ideia era simples: poder crescer o disco depois sem dor de cabeça e já deixar o storage preparado para as roles de arquivos.

Abaixo eu mostro passo a passo o que fiz e por que escolhi cada opção.

---

### 1. Topologia do Laboratório
<img src="img/1.png" width="800">

> Aqui é o Hyper-V com as 4 VMs do lab (`CXB-DC01`, `DC02`, `FS01` e `WIN10`). Separei o file server em uma VM só pra ele, assim o tráfego de arquivos não compete com o AD.

---

### 2. Provisionamento Físico (Discos Virtuais)
<img src="img/2.png" width="800">

> Adicionei 3 VHDX de 20GB cada na controladora SCSI do FS01. Deixei como dinâmico porque é lab e eu não queria comer espaço do meu SSD à toa.

---

### 3. Criação do Storage Pool
<img src="img/3.png" width="800">

> Peguei os 3 discos zerados e juntei tudo num pool só, chamei de `POOL-DADOS-CXB`. Com o pool eu esqueço o disco físico e trato tudo como um único tanque de armazenamento.

---

### 4. Nomeação e Conceito de Storage Tiering
<img src="img/4.png" width="800">

> O Tiering ficou cinza porque meus 3 discos são iguais. Em produção eu usaria SSD + HDD aqui, o Windows joga arquivo quente pro SSD e o frio pro HDD sozinho. No lab só deixei anotado pra lembrar.

---

### 5. Layout de Armazenamento (Simple)
<img src="img/5.png" width="800">

> Escolhi **Simple**. Não é porque é mais fácil, é porque meus 3 VHDX estão no mesmo SSD físico. Se eu colocasse Mirror eu só ia perder espaço sem ganhar proteção real. Em servidor físico eu iria de Mirror ou Parity sem pensar duas vezes.

---

### 6. Tipo de Provisionamento (Thin)
<img src="img/6.png" width="800">

> Deixei em **Thin**. O Windows acha que tem o espaço todo, mas só ocupa no host quando eu realmente gravo algo. É o que a gente faz em nuvem pra não desperdiçar disco.

---

### 7. Overprovisioning e Write-back Cache
<img src="img/7.png" width="800">

> Com Thin eu consegui criar um disco maior que o pool. Isso é overprovisioning, técnica que provedor usa pra vender mais do que tem e comprar disco depois. Ativei o write-back cache também, ele segura pico de gravação e o usuário não sente lag.

---

### 8. Validação do SMB Multichannel
<img src="img/8.png" width="800">

> Rodei `Get-SmbServerConfiguration` só pra confirmar. O Multichannel já vem ligado. No lab com uma placa não muda nada, mas se eu colocar duas NICs de 1Gb ele soma a banda e se um cabo cair o outro segura.

---

### 9. Resultado Final (Volume E:)
<img src="img/9.png" width="800">

> Formatei o volume como `Dados-CXB` em **NTFS** no E:. Precisa ser NTFS porque dedup e FSRM não funcionam direito em outro sistema de arquivos.

## 2. Estrutura de Dados e Otimização (Dedup e DFS-N)

Depois do storage pronto, transformei aquele disco cru em um serviço de arquivos de verdade. O foco aqui era economizar espaço e criar um caminho que não quebrasse se eu trocasse de servidor.

---

### 2.1. Instalação de Roles e Recursos Críticos
<img src="img/10.png" width="800">

> Instalei Data Deduplication, DFS Namespaces, DFS Replication e FSRM. É o combo básico de qualquer file server corporativo hoje.

---

### 2.2. Otimização de Storage: Data Deduplication
<img src="img/11.png" width="800">

> Apliquei a dedup só no E:. Deixei o C: de fora pra não arriscar performance do sistema.

<img src="img/12.png" width="800">

> Configurei o agendamento: otimização em background o tempo todo e uma faxina pesada às 02:00 por 6 horas. Coloquei de madrugada pra não brigar com usuário usando arquivo.

---

### 2.3. Abstração de Rede: DFS Namespaces (DFS-N)
<img src="img/13.png" width="800">

> Criei o DFS pra esconder o servidor físico atrás de um nome lógico.

<img src="img/15.png" width="800">

> Errei na primeira tentativa e deixei o caminho padrão `C:\DFSRoots`. Percebi que assim eu ignorava todo o pool que acabei de criar. Apaguei e forcei para **`E:\Arquivos`**.
> * Por que mudei: se ficasse no C:, nada de dedup ou quota