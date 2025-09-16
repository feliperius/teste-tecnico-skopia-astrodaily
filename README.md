# TestSkopiaAstroDaily

Um aplicativo iOS para visualizar a Astronomia do Dia (APOD) da NASA, desenvolvido em SwiftUI seguindo as melhores práticas de desenvolvimento iOS.

## 📋 Descrição

O aplicativo consome a API da NASA para exibir a imagem astronômica do dia, permitindo aos usuários navegar por diferentes datas, visualizar detalhes das imagens e salvar suas favoritas.

## 🏗️ Arquitetura e Decisões Técnicas

### Arquitetura MVVM
- **Justificativa**: Escolhida para separar claramente a lógica de negócio da interface, facilitando testes e manutenção
- **ViewModels**: Gerenciam estado e lógica de negócio usando `@ObservableObject` e `@Published`
- **Views**: Focadas apenas na apresentação usando SwiftUI
- **Models**: Estruturas de dados simples e bem definidas

### Tecnologias Utilizadas
- **Linguagem**: Swift 5.0+
- **UI Framework**: SwiftUI
- **Gerenciamento de Dependências**: Swift Package Manager
- **Persistência**: Core Data
- **Networking**: Alamofire + async/await
- **Cache de Imagens**: Kingfisher
- **Arquitetura**: MVVM + Repository Pattern

### Estrutura do Projeto
```
TestSkopiaAstroDaily/
├── Core/
│   ├── Networking/          # Camada de rede
│   ├── Persistence/         # Core Data stack e stores
│   ├── Managers/           # Gerenciadores de funcionalidades
│   ├── Repository/         # Padrão Repository
│   └── Errors/             # Tratamento de erros
├── Features/
│   ├── Splash/             # Tela de splash animada
│   ├── Feed/               # Feed principal
│   ├── List/               # Lista de APODs
│   ├── Detail/             # Detalhes do APOD
│   └── Favorites/          # Favoritos
├── Utils/                  # Utilitários e extensões
└── Localizable/           # Localização PT-BR/EN
```

### Principais Decisões Técnicas

#### 1. **Core Data para Persistência**
- **Escolha**: Core Data ao invés de UserDefaults
- **Justificativa**: 
  - Melhor performance para listas grandes
  - Relacionamentos complexos
  - Queries avançadas
  - Thread safety nativo

#### 2. **Kingfisher para Cache de Imagens**
- **Migração**: Nuke → Kingfisher
- **Justificativa**:
  - Melhor integração com SwiftUI
  - Cache mais eficiente
  - Menor footprint de memória

#### 3. **Repository Pattern**
- **Implementação**: Abstração entre ViewModels e fontes de dados
- **Benefícios**:
  - Facilita testes unitários
  - Separação clara de responsabilidades
  - Flexibilidade para mudanças futuras

#### 4. **Async/Await**
- **Uso**: Todas operações assíncronas
- **Benefícios**:
  - Código mais limpo e legível
  - Melhor tratamento de erros
  - Evita callback hell

#### 5. **Localização**
- **Suporte**: Português (BR) e Inglês
- **Implementação**: Strings centralizadas
- **Estrutura**: Arquivos `.strings` separados

## 🚀 Como Rodar o Projeto

### Pré-requisitos
- **Xcode**: 15.0+
- **iOS**: 17.0+
- **macOS**: Sonoma 14.0+

### Configuração

1. **Clone o repositório**:
```bash
git clone [URL_DO_REPOSITORIO]
cd TestSkopiaAstroDaily
```

2. **Abra o projeto no Xcode**:
```bash
open TestSkopiaAstroDaily.xcodeproj
```

3. **Configure a API Key da NASA**:
   - Abra o arquivo `Core/Secrets.plist`
   - Adicione sua API key da NASA:
   ```xml
   <key>NASA_API_KEY</key>
   <string>SUA_API_KEY_AQUI</string>
   ```
   - Obtenha uma API key gratuita em: https://api.nasa.gov/

4. **Execute o projeto**:
   - Selecione um simulador iOS
   - Pressione `Cmd + R` ou clique em "Run"

### Dependências
As dependências são gerenciadas automaticamente pelo SPM:
- **Alamofire**: Networking
- **Kingfisher**: Cache de imagens

## 🧪 Testes

```bash
# Executar testes unitários
cmd + u

# Executar testes de UI
# Selecione o scheme TestSkopiaAstroDailyUITests
```

## 🎯 Funcionalidades

### ✅ Implementadas
- [x] Splash screen animada com créditos
- [x] Feed principal com APOD do dia
- [x] Lista de APODs com navegação por datas
- [x] Visualização detalhada com zoom
- [x] Sistema de favoritos com Core Data
- [x] Suporte a imagens e vídeos
- [x] Localização PT-BR/EN
- [x] Tratamento de erros robusto
- [x] Cache de imagens otimizado
- [x] Interface responsiva

### 🎨 Interface
- Design moderno e intuitivo
- Animações suaves
- Modo escuro nativo
- Splash screen personalizada
- Indicadores de carregamento

## 🔧 Pontos de Melhoria

### 📈 Performance
- [ ] **Paginação**: Implementar carregamento incremental na lista
- [ ] **Prefetch**: Pre-carregamento de imagens adjacentes
- [ ] **Cache Strategy**: Cache de rede mais inteligente
- [ ] **Image Compression**: Otimização automática de imagens

### 🧪 Testes
- [ ] **Unit Tests**: Cobertura de 80%+ nos ViewModels
- [ ] **Integration Tests**: Testes de integração com API
- [ ] **UI Tests**: Automação de fluxos principais
- [ ] **Snapshot Tests**: Testes visuais de regressão

### 🏗️ Arquitetura
- [ ] **Dependency Injection**: Container de DI (Swinject)
- [ ] **Coordinator Pattern**: Navegação centralizada
- [ ] **Use Cases**: Camada de casos de uso
- [ ] **Clean Architecture**: Evolução para Clean Architecture

### 📱 Funcionalidades
- [ ] **Compartilhamento**: Share de imagens e informações
- [ ] **Notificações**: Push notifications para novos APODs
- [ ] **Pesquisa**: Busca por título ou data
- [ ] **Filtros**: Filtros por tipo (imagem/vídeo)
- [ ] **Offline Mode**: Funcionalidade offline básica
- [ ] **Apple Watch**: Extensão para watchOS

### 🎨 UI/UX
- [ ] **Tema Personalizado**: Múltiplos temas
- [ ] **Acessibilidade**: Melhorias de accessibility
- [ ] **iPad Support**: Layout otimizado para iPad
- [ ] **Widgets**: Widget para tela inicial
- [ ] **3D Touch**: Peek & Pop para preview

### 🔒 Segurança
- [ ] **SSL Pinning**: Segurança adicional na rede
- [ ] **Keychain**: Armazenamento seguro de credenciais
- [ ] **Biometria**: Autenticação biométrica opcional

## 📊 Métricas e Analytics

### Sugestões de Implementação
- [ ] **Firebase Analytics**: Tracking de eventos
- [ ] **Crashlytics**: Monitoramento de crashes
- [ ] **Performance Monitoring**: Métricas de performance

## 🎯 Roadmap

### v1.1 (Próxima Release)
- Testes unitários completos
- Modo offline básico
- Melhorias de performance

### v1.2 (Futuro)
- Apple Watch support
- Widgets iOS
- Notificações push

### v2.0 (Longo Prazo)
- Clean Architecture completa
- Modo multi-usuário
- Sincronização na nuvem

## 👨‍💻 Desenvolvedor

**Felipe Perius**
- GitHub: [@feliperius](https://github.com/feliperius)

## 📄 Licença

Este projeto é um teste técnico desenvolvido para demonstração de habilidades em desenvolvimento iOS.

---

### 📝 Notas de Desenvolvimento

#### Comandos Úteis
```bash
# Limpar cache do Xcode
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset simulator
xcrun simctl erase all

# Build via terminal
xcodebuild -project TestSkopiaAstroDaily.xcodeproj -scheme TestSkopiaAstroDaily -destination 'platform=iOS Simulator,name=iPhone 15' build
```

#### Estrutura de Commits
- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `refactor:` Refatoração de código
- `style:` Mudanças de estilo/formatação
- `test:` Adição de testes
- `docs:` Documentação

#### API Endpoints Utilizados
- **APOD**: `https://api.nasa.gov/planetary/apod`
- **Rate Limit**: 1000 requests/hora (com API key)