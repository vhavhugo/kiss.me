# Kiss Me - "Porque tudo começa com um beijo"

![Kiss Me Logo](assets/images/app_icon.png)

Kiss Me é um aplicativo de relacionamentos de próxima geração, focado em **hiperlocalização** e **gamificação estratégica**. Diferente do modelo de "swipe infinito", o Kiss Me utiliza o "Jogo das 3 Cartas" para reduzir a paralisia de escolha e fomentar conexões reais e imediatas.

---

## 🔬 Fundamentação Teórica e Pesquisa Acadêmica

Este projeto é baseado em uma síntese abrangente de literatura científica, design e tecnologia, garantindo a validade das escolhas de produto.

### 🔍 Estratégias de Busca Utilizadas

Para consolidar esta arquitetura, foram utilizadas as seguintes strings de busca em bases como *Consensus, Semantic Scholar, PubMed, GitHub e TechBlogs*:

#### 🎨 Foco em Design, Cores e Experiência do Usuário
> `"dating app" AND (layout OR wireframe) AND ("color palette" OR "dark mode") AND "user experience"`
>
> `"aplicativo de namoro" AND (design de interface OR UX) AND (psicologia das cores OR acessibilidade)`

#### 🛠️ Foco em Arquitetura Tecnológica e Recursos de IA
> `"dating platform" AND ("tech stack" OR backend) AND ("geolocation API" OR "real-time chat") AND ("matching algorithm" OR LLM)`
>
> `"aplicativo de relacionamento" AND (segurança OR "verificação por foto") AND (arquitetura OR escalabilidade OR "banco de dados")`

#### 🔬 Pesquisa Completa e Avançada (Combinação Total)
> `("dating app" OR "dating platform") AND (UI OR UX OR "visual design") AND (colors OR branding) AND (AI OR "machine learning") AND (security OR privacy)`

---

## 1. IA e Retenção de Usuários
As evidências são contraditórias sobre se o sistema de busca de pares baseado em inteligência artificial melhora a retenção de usuários. A literatura sugere que:
- **Confiança Algorítmica**: A percepção de justiça da IA está ligada à crença na eficácia do matchmaking (Paul, 2023).
- **Fadiga Decisória**: O uso excessivo de swipe leva os usuários a recorrerem a algoritmos como alívio para comportamentos compulsivos (Binder, 2024).
- **Eficácia vs. Realidade**: Modelos de ML preveem interesse mútuo com 85-94% de precisão (Guo, 2025), mas a compatibilidade real só é percebida offline (Sharabi, 2020).

## 2. Transparência e Explicabilidade (XAI)
A transparência nos algoritmos de combinação pode construir ou corroer a confiança dependendo do estilo da explicação:
- **Explicações Locais**: Justificam correspondências individuais, prevenindo queda de confiança em momentos críticos.
- **Explicações Globais**: Promovem a compreensão geral do sistema e sua lógica.
- **Efeito de Sobrecarga**: O excesso de transparência técnica pode confundir; o ideal são explicações contextuais em linguagem simples (Sunny, 2025).

| Tipo de Explicação | Impacto na Confiança | Aplicação no Kiss Me |
| :--- | :--- | :--- |
| **Local** | Impede a queda de confiança durante erros. | Justificar o radar instantâneo. |
| **Global** | Melhora a compreensão posterior do modelo. | FAQ e Tutorial do Radar. |
| **Combinado** | Ideal para estabelecer confiança adequada. | Transição entre busca e perfil. |

## 3. UX Algorítmica, Branding e Cores
A cor é o elemento mais intuitivo e emocional no design de interfaces (Jiang, 2024).
- **Psicologia das Cores**: Tons quentes transmitem calor e suavidade; laranja é preferido por 60,2% dos usuários (Liu, 2024).
- **Saturação e Fadiga**: Fundos com baixa saturação reduzem a fadiga ocular e aceleram tarefas de busca visual (Deng, 2022).
- **Autenticidade**: O estilo visual deve refletir a personalidade para uma apresentação autêntica da "marca pessoal" (Lestari, 2024).

## 4. Gamificação e Mecânicas de Jogo
O Kiss Me substitui o "Baralho Infinito" (caça-níquel) por um modelo finito de 3 opções:
- **Recompensa Variável**: O match intermitente alimenta o uso compulsivo (Zytko, 2018).
- **Inércia Social**: 80% dos usuários reconhecem táticas de manipulação, mas sua eficácia não diminui (Akbar, 2026).
- **O Jogo das 3 Cartas**: Reduz a paralisia de análise e aumenta a qualidade das interações.

## 5. Segurança e Privacidade
A segurança é a prioridade #1. A integração de IA no Kiss Me foca em:
- **Detecção de Maliciosos**: Modelos que analisam integridade de informação superam métodos tradicionais em 8% de precisão (Shen, 2023).
- **Design Participativo**: Foco em estratégias de segurança para mulheres (Datey, 2024).
- **Processamento On-Device**: Uso de visão computacional afetiva sem criar infraestrutura de vigilância (Kandala, 2026).

---

## 💰 Estratégia de Monetização
- **Curiosidade Emocional**: Microtransações para revelação imediata de curtidas (Pettersen, 2023).
- **Valor Percebido**: O gasto deve parecer uma escolha racional para potencializar a conexão (Runge, 2022).
- **Níveis de Assinatura**: Uso de recursos como "prioridade" e "geolocalização expandida" de forma equilibrada.

---

## 🛠️ Stack Tecnológico
- **Frontend**: Flutter (Dart) - Clean Architecture.
- **Backend**: Supabase (PostgreSQL + PostGIS).
- **Cache de Localização**: Redis (Upstash) - Comandos GEO para performance extrema.
- **IA**: Gemini/OpenAI para moderação e icebreakers.

---

## 🚀 Como Executar o Projeto
1. Clone o repositório.
2. Certifique-se de que o Flutter 3.44+ está instalado.
3. Configure `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY` com `--dart-define`.
4. Execute `flutter pub get`.
5. Execute `flutter run`.

### Configurar o Supabase para ficar online

O aplicativo não usa mais uma URL fixa. Pegue no Supabase Dashboard o **Project URL** e a chave **Publishable key** do projeto correto e inicie assim:

```bash
flutter run -d chrome \
	--dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co \
	--dart-define=SUPABASE_PUBLISHABLE_KEY=sua-chave-publishable
```

Depois execute [supabase/chat_schema.sql](supabase/chat_schema.sql) no SQL Editor. O usuário também precisa estar autenticado no Supabase; o usuário local simulado não substitui uma sessão real para as políticas RLS.

### Habilitar login com Google

O botão Google depende do provider Google habilitado no mesmo projeto Supabase usado em `SUPABASE_URL`:

1. Abra `Authentication > Providers > Google` no Supabase Dashboard.
2. Ative o provider.
3. Crie ou selecione um OAuth Client ID do tipo **Web application** no Google Cloud Console.
4. Informe o Client ID e o Client Secret no provider Google do Supabase.
5. No Google Cloud Console, adicione a URL de callback exibida pelo Supabase em **Authorized redirect URIs**.
6. Em `Authentication > URL Configuration`, adicione a URL usada pelo app, por exemplo `http://localhost:8080`.

Sem essa configuração, o Supabase retorna:

```json
{"code":400,"error_code":"validation_failed","msg":"Unsupported provider: provider is not enabled"}
```

O aplicativo exibe esse erro como uma instrução para habilitar o Google, em vez de iniciar uma sessão falsa.

### Executar sem Xcode

Para executar no macOS sem instalar o Xcode, use o Flutter Web no Chrome:

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

Também é possível gerar uma versão estática:

```bash
flutter build web
```

O build web foi validado com sucesso. Chamadas WebRTC funcionam no Chrome com permissão de câmera e microfone; para chamadas entre dispositivos, o Supabase precisa estar configurado e a infraestrutura deve incluir STUN/TURN quando a conexão direta não for possível.

Se o console mostrar `Falling back to CPU-only rendering` ou `webGLVersion is -1`, o Chrome iniciou sem WebGL. Isso é um aviso de renderização, não um erro do Supabase nem do aplicativo. No Chrome, abra `chrome://settings/system`, ative **Usar aceleração gráfica quando disponível**, reinicie o navegador e confirme em `chrome://gpu` que **WebGL** está acelerado. Depois execute novamente:

```bash
flutter run -d chrome
```

Se o navegador continuar bloqueando a GPU, abra uma nova instância do Chrome com:

```bash
open -na "Google Chrome" --args --enable-webgl --ignore-gpu-blocklist --enable-gpu-rasterization
```

O destino `macOS` nativo não pode ser compilado somente com Command Line Tools: ele exige o Xcode completo e o `xcodebuild`.

---
© 2026 Kiss Me - Porque tudo começa com um beijo.
