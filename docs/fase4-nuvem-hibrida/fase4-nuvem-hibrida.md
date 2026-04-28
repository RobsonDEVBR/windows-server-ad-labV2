# Fase 4: Identidade Híbrida — AD DS + Microsoft Entra ID

O objetivo desta fase é conectar o AD local ao Entra ID para que os usuários de Caxambu e BH tenham uma identidade única na nuvem e no domínio — mesmo login para o Windows, Microsoft 365 e qualquer serviço SaaS integrado ao tenant (SSO). O método de sincronização escolhido foi **Password Hash Sync (PHS)**.

> **Nota:** O Entra Connect foi instalado no próprio `CXB-DC01` por limitação de recursos do lab. Em produção, o correto é usar um servidor membro dedicado para essa função — o DC não deveria acumular mais uma role crítica.

---

## Tentativa 1: Microsoft Entra Cloud Sync

Comecei pelo Cloud Sync, que é o método mais recente da Microsoft — um agente leve instalado no servidor local que se comunica diretamente com a nuvem, sem precisar de infraestrutura adicional de sincronização.

| Evidência | Descrição |
|-----------|-----------|
| [![1](img/1.png)](img/1.png) | Início da instalação do Cloud Provisioning Agent no `CXB-DC01` |
| [![2](img/2.png)](img/2.png) | Conta de serviço configurada como gMSA — sem senha manual para gerenciar, sem rotação periódica para esquecer |
| [![3](img/3.png)](img/3.png) | Domínio `robson.local` vinculado com credenciais de administrador para leitura do diretório |
| [![4](img/4.png)](img/4.png) | Revisão dos parâmetros antes de registrar o agente no Azure |
| [![5](img/5.png)](img/5.png) | Agente aparecendo como "Ativo" no portal Entra — comunicação via NAT funcionando |
| [![6](img/6.png)](img/6.png) | Bloqueio: o Cloud Sync exige licença P1/P2 para funcionar. O trial da Microsoft pede CNPJ ou cartão para liberar — fim da linha para o lab |

---

## Tentativa 2: Microsoft Entra Connect Sync (Classic)

Com o Cloud Sync bloqueado por licenciamento, migrei para o **Entra Connect Classic**. A sincronização básica é gratuita e cobre tudo que o lab precisa.

A diferença principal em relação ao Cloud Sync: o Connect Classic instala um banco SQL Express local e roda um motor de sincronização completo no servidor. Mais pesado, mais antigo, mas sem custo e sem restrição de licença para o cenário deste lab.

| Evidência | Descrição |
|-----------|-----------|
| [![7](img/7.png)](img/7.png) | Instalação com configuração expressa — SQL Express instalado localmente junto com o motor de sync |
| [![8](img/8.png)](img/8.png) | Aviso de UPN: o sufixo `.local` não é roteável na internet e não existe no tenant do Entra. Para o lab, segui sem correspondência — o login na nuvem vai usar o sufixo padrão do tenant, mas o SID e os atributos do objeto continuam amarrados ao AD local |
| [![9](img/9.png)](img/9.png) | Wizard configurando permissões de leitura e escrita no AD e preparando o motor de exportação |
| [![10](img/10.png)](img/10.png) | Synchronization Service Manager mostrando **Success** em todas as etapas de Import e Export |

---

## Resultado

Os usuários e grupos criados localmente em Caxambu e BH estão sincronizados e visíveis no portal Microsoft Entra. A base para SSO está estabelecida — mesma credencial para login no Windows e nos serviços em nuvem integrados ao tenant.

O bloqueio do Cloud Sync por licenciamento virou um exercício de diagnóstico útil: entender por que a Microsoft separou os dois métodos e o que cada um exige operacionalmente é parte do aprendizado desta fase.