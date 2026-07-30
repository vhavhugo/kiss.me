# Kiss Me - "Porque tudo começa com um beijo"

![Kiss Me Logo](assets/images/app_icon.png)

Kiss Me é um aplicativo de relacionamentos de próxima geração, focado em **hiperlocalização** e **gamificação estratégica**. Diferente do modelo de "swipe infinito", o Kiss Me utiliza o "Jogo das 3 Cartas" para reduzir a paralisia de escolha e fomentar conexões reais e imediatas.

---

## 🔬 Fundamentação Teórica e Pesquisa Acadêmica

Este projeto é baseado em uma síntese abrangente de literatura científica (IHC, Sistemas Sociais Computacionais e Sociologia Cultural). 

### 🔍 Estratégia de Busca Acadêmica
Para garantir a validade das escolhas de design, IA e segurança, foi utilizada a seguinte string de busca em bases como *Consensus, Semantic Scholar e PubMed*:

> `("dating app" OR "dating platform") AND (UI OR UX OR "visual design") AND (colors OR branding) AND (AI OR "machine learning") AND (security OR privacy)`

---

## 1. IA e Retenção de Usuários

As evidências sobre se algoritmos de IA melhoram a retenção são indiretas. O engajamento é mantido pela **percepção de eficácia** e confiança no sistema.

- **Confiança Algorítmica**: A percepção de justiça da IA está ligada à crença na eficácia do matchmaking (Paul, 2023).
- **Fadiga Decisória**: O uso excessivo de swipe leva os usuários a recorrerem a algoritmos como estratégia de alívio para comportamentos compulsivos (Binder, 2024).
- **Eficácia vs. Realidade**: Algoritmos preveem interesse mútuo com 85-94% de precisão (Guo, 2025), mas a compatibilidade a longo prazo só é perceptível após o encontro offline (Sharabi, 2020).

---

## 2. Transparência e Explicabilidade (XAI)

A transparência é uma "faca de dois gumes": deve ser clara e contextual para não sobrecarregar o usuário.

| Tipo de Explicação | Impacto na Confiança | Aplicação no Kiss Me |
| :--- | :--- | :--- |
| **Local** | Previne queda de confiança em momentos críticos. | Justificar por que *esta* pessoa está no seu radar agora. |
| **Global** | Promove compreensão geral do sistema. | Tutorial e FAQ sobre o funcionamento do radar. |
| **Combinado** | Ideal para estabelecer confiança adequada. | Transição fluida entre a busca de KM e a exibição do perfil. |

---

## 3. UX Algorítmica, Branding e Cores

A interface do Kiss Me foi projetada para minimizar a fricção cognitiva e maximizar a ressonância emocional.

### 🎨 Psicologia das Cores
- **Tons Quentes**: Transmitem calor e suavidade (preferidos por 60,2% dos usuários - Liu, 2024).
- **Baixa Saturação**: Reduz a fadiga ocular e melhora o desempenho de busca visual (Deng, 2022).
- **Alta Luminosidade**: Transmite emoções puras e limpas.

### 🎮 Gamificação e Recompensas
O Kiss Me substitui o "Baralho Infinito" (tipo Slot Machine) por uma mesa de **3 Cartas**, combatendo o uso compulsivo e a despersonalização dos vínculos humanos (Nader, 2024; Zytko, 2018).

---

## 4. Segurança e Privacidade

Segurança é a prioridade #1. A integração de IA no Kiss Me foca em:
- **Verificação de Perfil**: Uso de visão computacional para combater o engano visual da IA generativa (Barkallah, 2026).
- **Detecção de Maliciosos**: Modelos de confiança que analisam comportamentos para prevenir danos online-to-offline (Shen, 2023).
- **Processamento On-Device**: Foco em privacidade para dados sensíveis.

---

## 💰 Estratégia de Monetização

O Kiss Me utiliza um modelo de **Valor Percebido**, onde o gasto deve parecer uma escolha racional e recompensadora.

- **Curiosidade Imediata**: Microtransações para revelação de interações.
- **Assinaturas em Nível**: Desbloqueio de filtros avançados e visibilidade.
- **Justiça Percebida**: Evitar monetização agressiva que corrói a confiança do usuário (Salehudin, 2022).

---

## 🛠️ Stack Tecnológico

- **Frontend**: Flutter (Dart) - Clean Architecture.
- **Backend**: Supabase (PostgreSQL + PostGIS).
- **Cache de Localização**: Redis (Upstash) - Comandos GEO para alta performance.
- **IA**: Gemini/OpenAI para moderação e icebreakers.

---

## 🚀 Como Executar o Projeto

1. Clone o repositório.
2. Certifique-se de que o Flutter 3.44+ está instalado.
3. Configure as chaves no arquivo `.env` (Redis, Supabase, Google/Instagram API).
4. Execute `flutter pub get`.
5. Execute `flutter run`.

---
© 2026 Kiss Me - Porque tudo começa com um beijo.
