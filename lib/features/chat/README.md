# Aba Chats

Módulo de comunicação em tempo real do Kiss Me. A aba Chats permite enviar mensagens de texto, áudio e vídeo usando Flutter, Riverpod e Supabase.

## Pesquisa e referências de arquitetura

As strings abaixo podem ser usadas para aprofundar as decisões técnicas do módulo.

### Arquitetura e tech stack

```text
"system architecture" AND "real-time messaging app" AND "high concurrency" AND "tech stack"
```

### Protocolos de mensagens em tempo real

```text
"best real-time protocol" AND ("XMPP" OR "WebSockets" OR "MQTT") AND "scalable chat backend"
```

### Backend de alta performance

```text
"building a chat app" AND ("Erlang" OR "Elixir" OR "Golang") AND "millions of concurrent connections"
```

### Chamadas e segurança

```text
"WebRTC architecture" AND "peer-to-peer video call" AND "Signal protocol" AND "end-to-end encryption"
```

### Dicionário técnico

- **High Concurrency:** capacidade de manter muitos usuários conectados e ativos ao mesmo tempo sem degradar o serviço.
- **WebSockets / Long Polling:** tecnologias para manter ou simular uma conexão aberta e entregar eventos rapidamente ao cliente.
- **WebRTC:** padrão aberto para comunicação de áudio, vídeo e dados em tempo real entre dispositivos.
- **STUN:** serviço que ajuda o WebRTC a descobrir uma rota pública para a conexão.
- **TURN:** relay usado quando a conexão direta entre os participantes não é possível.
- **DTLS-SRTP:** conjunto usado pelo WebRTC para autenticar e proteger os fluxos de áudio e vídeo em trânsito.
- **E2EE:** criptografia ponta a ponta, em que somente os participantes devem conseguir acessar o conteúdo.
- **Signal Protocol:** protocolo de mensagens E2EE com estabelecimento de chaves e ratcheting; não é implementado automaticamente pelo WebRTC.

## Funcionalidades

- Mensagens de texto persistidas no Supabase.
- Atualização em tempo real com Supabase Realtime.
- Seleção de arquivos de áudio e vídeo pelo `file_picker`.
- Upload de mídia para o bucket `chat-media`.
- Exibição de mensagens próprias e recebidas com estilos diferentes.
- Estado de carregamento e tratamento de falhas de envio.
- Indicador de conexão do stream e limite de 25 MB para mídia.
- Chamada de vídeo WebRTC com câmera local, vídeo remoto, áudio e controles de encerramento.

## Tudo que foi criado

### Interface da aba

- [chat_page.dart](presentation/pages/chat_page.dart) substitui o placeholder da aba Chats.
- Campo para texto com envio por botão ou tecla de confirmação.
- Botões de seleção de áudio e vídeo.
- Botão para iniciar chamada de vídeo.
- Bolhas diferentes para mensagens próprias e recebidas.
- Horário exibido nas mensagens de texto.
- Estado de carregamento, erro e reconexão do stream.
- Botão de reconexão que invalida o provider sem reiniciar o aplicativo.

### Mensagens e arquivos

- [chat_message.dart](domain/entities/chat_message.dart) define a entidade `ChatMessage`.
- `ChatMessageType` restringe mensagens a `text`, `audio` e `video`.
- Texto é salvo em `public.chat_messages`.
- Áudio e vídeo são selecionados com `file_picker`.
- Arquivos são limitados a 25 MB antes do upload.
- Mídia é enviada para o bucket `chat-media`.
- A URL do arquivo é registrada junto com o tipo e o nome original.

### Camada de dados

- [chat_repository.dart](domain/repositories/chat_repository.dart) define o contrato do chat.
- [chat_repository_impl.dart](data/repositories/chat_repository_impl.dart) implementa persistência, stream Realtime e Storage.
- [chat_provider.dart](presentation/providers/chat_provider.dart) expõe os providers Riverpod.
- O stream carrega no máximo 100 mensagens recentes por conversa.
- Envios de texto têm timeout de 10 segundos.
- Uploads têm timeout de 60 segundos.
- O envio simultâneo é bloqueado na interface para reduzir pressão de rede.

### Chamada WebRTC

- [video_call_page.dart](presentation/pages/video_call_page.dart) gerencia a chamada.
- `flutter_webrtc` acessa câmera, microfone e renderizadores local/remoto.
- SDP usa mensagens `offer` e `answer`.
- ICE candidates são trocados pela tabela `call_signals`.
- Supabase Realtime funciona como canal de sinalização.
- STUN está configurado para descoberta de rota.
- DTLS-SRTP fornece a proteção nativa do fluxo WebRTC.
- Controles permitem silenciar microfone, desligar câmera e encerrar chamada.
- Android declara câmera, microfone e Internet.
- iOS declara as descrições de uso de câmera e microfone.

O WebRTC não implementa Signal Protocol ou Double Ratchet automaticamente. A chamada atual usa a proteção DTLS-SRTP do WebRTC. Para produção, ainda é necessário configurar TURN e implementar convite/aceite com um `callId` compartilhado pelo participante correto.

## Arquitetura

```text
ChatPage
  -> chatMessagesProvider / chatControllerProvider
  -> ChatRepository
  -> ChatRepositoryImpl
  -> Supabase Database + Supabase Storage
```

## Decisão de protocolo

O módulo usa o Supabase Realtime, que mantém uma conexão persistente baseada em WebSocket para distribuir alterações da tabela `chat_messages`. Essa escolha combina bem com o backend já adotado pelo aplicativo: o banco mantém a fonte de verdade e o Realtime entrega os eventos aos clientes.

XMPP e MQTT não foram adicionados porque exigiriam um servidor/broker separado, autenticação própria e uma segunda fonte de estado. gRPC e QUIC podem ser avaliados quando existir um gateway de microsserviços dedicado; não são necessários para o fluxo Flutter + Supabase atual.

O cliente aplica duas proteções simples contra pressão de rede: impede envios simultâneos na interface e rejeita arquivos acima de 25 MB. Operações de texto expiram em 10 segundos e uploads em 60 segundos para evitar requisições presas indefinidamente.

## Princípios de resiliência aproveitados

- **Mensagens tipadas:** `ChatMessageType` restringe o protocolo a `text`, `audio` e `video`, evitando payloads ambíguos.
- **Isolamento de falhas:** a UI trata erro do stream e erro de envio separadamente; uma falha de mídia não encerra a conversa inteira.
- **Supervisão no cliente:** o provider pode ser invalidado pelo botão de reconexão, reabrindo a assinatura Realtime sem reiniciar o aplicativo.
- **Estado limitado:** o stream mantém no máximo as 100 mensagens mais recentes da conversa, reduzindo memória e custo de sincronização.

Erlang/Elixir ou Go só devem ser introduzidos quando houver uma necessidade operacional concreta, como um gateway próprio para milhões de conexões, presença distribuída ou processamento de eventos fora do Supabase. Para a escala atual, adicionar esse runtime aumentaria a complexidade sem melhorar o fluxo funcional da aba Chats.

## Chamada de vídeo

A chamada usa WebRTC com:

- Sinalização SDP e ICE pela tabela `call_signals` via Supabase Realtime.
- STUN para descoberta de rota direta.
- SRTP sobre DTLS para criptografia nativa do áudio e vídeo em trânsito.
- `flutter_webrtc` para câmera, microfone e renderização dos streams.

O WebRTC não implementa o Signal Protocol nem Double Ratchet automaticamente. Portanto, a chamada não deve ser descrita como Signal E2EE; a proteção atual é a fornecida por DTLS-SRTP. Para redes restritivas, é necessário adicionar um servidor TURN e configurar suas credenciais em `video_call_page.dart`.

O botão de chamada já abre a negociação WebRTC. Para produção, o próximo passo é criar o convite persistido para o participante da conversa, permitindo que ele aceite a chamada e receba o mesmo `callId`. O `callId` não deve ser derivado apenas no cliente em uma chamada multiusuário.

### Camadas

- `domain/entities/chat_message.dart`: entidade e tipos de mensagem.
- `domain/repositories/chat_repository.dart`: contrato do serviço de chat.
- `data/repositories/chat_repository_impl.dart`: persistência, realtime e upload de mídia.
- `presentation/providers/chat_provider.dart`: providers Riverpod e controller de envio.
- `presentation/pages/chat_page.dart`: interface da aba Chats.
- `presentation/pages/video_call_page.dart`: negociação e interface da chamada WebRTC.

## Configuração do Supabase

Execute [chat_schema.sql](../../../supabase/chat_schema.sql) no SQL Editor do Supabase. O script cria:

- A tabela `public.chat_messages`.
- A tabela `public.call_signals` para ofertas, respostas e ICE candidates.
- Índice por conversa e data de criação.
- Políticas RLS para leitura e inserção.
- A publicação `supabase_realtime` para sincronização das mensagens.
- A publicação `supabase_realtime` para sincronização dos sinais WebRTC.
- O bucket público `chat-media`.
- Políticas de leitura e upload de arquivos de mídia.

O schema precisa ser executado antes de abrir a aba Chats. Sem ele, o stream exibirá a mensagem de indisponibilidade da conversa.

## Modelo de dados

| Campo | Tipo | Descrição |
| --- | --- | --- |
| `id` | `bigint` | Identificador da mensagem |
| `conversation_id` | `text` | Identificador da conversa |
| `sender_id` | `text` | Usuário que enviou |
| `message_type` | `text` | `text`, `audio` ou `video` |
| `content` | `text` | Texto ou URL do arquivo |
| `file_name` | `text` | Nome original do arquivo de mídia |
| `created_at` | `timestamptz` | Data de criação |

### `call_signals`

| Campo | Tipo | Descrição |
| --- | --- | --- |
| `call_id` | `text` | Identificador da chamada |
| `sender_id` | `text` | Participante que publicou o sinal |
| `signal_type` | `text` | `offer`, `answer` ou `candidate` |
| `payload` | `jsonb` | Dados SDP ou ICE |

## Fluxo de envio

### Texto

1. O usuário escreve a mensagem.
2. `ChatController.sendText` chama o repository.
3. A mensagem é inserida em `chat_messages`.
4. O Supabase Realtime atualiza `chatMessagesProvider`.

### Áudio e vídeo

1. O usuário seleciona um arquivo.
2. O arquivo é lido como bytes.
3. `ChatRepositoryImpl` envia o arquivo para `chat-media`.
4. A URL pública é registrada em `chat_messages`.
5. O stream atualiza a interface para todos os clientes conectados.

## Estado atual

O módulo usa temporariamente a conversa:

```dart
const chatConversationId = 'demo-conversation';
```

Para produção, esse valor deve vir da conversa selecionada pelo usuário. As políticas RLS também devem ser restringidas para permitir acesso somente aos participantes de cada conversa.

## Validação

Na raiz do projeto:

```bash
flutter pub get
flutter analyze lib/features/chat
flutter test test/widget_test.dart
```

O upload de mídia exige usuário autenticado no Supabase e o bucket `chat-media` configurado. O arquivo `.env` não é carregado automaticamente pelo Flutter; use os `--dart-define` documentados no README raiz.

## Dependências adicionadas

- `flutter_riverpod`: injeção de dependências e estado do chat.
- `supabase_flutter`: banco, Realtime, Storage e sinalização.
- `file_picker`: seleção de áudio e vídeo.
- `flutter_webrtc`: câmera, microfone e chamadas WebRTC.