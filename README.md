# Teste Técnico – Desenvolvedor iOS 

Um aplicativo iOS para visualizar a Astronomia do Dia da NASA, desenvolvido em SwiftUI seguindo as melhores práticas de desenvolvimento iOS.

## 📋 Descrição

O aplicativo consome a API da NASA para exibir a imagem astronômica do dia, permitindo aos usuários navegar por diferentes datas, visualizar detalhes das imagens e salvar suas favoritas.

## 🏗️ Arquitetura e Decisões Técnicas

### Arquitetura MVVM
- **Justificativa**: Escolhida para separar claramente a lógica de negócio da interface, facilitando testes e manutenção
- **ViewModels**: Gerenciam estado e lógica de negócio usando `@ObservableObject` e `@Published`
- **Views**: Focadas apenas na apresentação usando SwiftUI
- **Models**: Estruturas de dados simples usando struct e codable

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

### 🎭 Testes de UI

O projeto conta com **4 testes de UI essenciais** que cobrem as funcionalidades mais críticas da aplicação:

#### **Cobertura dos Testes Essenciais**

**� Launch Test** (`testAppLaunchesSuccessfully`)
- Verifica se o app abre sem crashes
- Valida que a tela principal aparece corretamente
- Teste de estabilidade básica

**📱 Content Display Test** (`testFeedDisplaysAPODContent`)
- Valida exibição do conteúdo APOD
- Verifica carregamento de título e imagem
- Teste de funcionalidade principal

**⬅️ Navigation Test** (`testNavigateToPreviousDay`)
- Testa navegação entre diferentes datas
- Valida estados dos botões de navegação
- Verifica carregamento após navegação

**⭐ Favorites Test** (`testToggleFavorite`)
- Testa funcionalidade de favoritos
- Verifica interação com botão de favorito
- Valida que o elemento permanece responsivo

#### **Estrutura Simplificada**

```
TestSkopiaAstroDailyUITests/
├── ComprehensiveUITests.swift    # EssentialUITests (4 testes principais)
├── FunctionalUITests.swift       # Arquivo mínimo (apenas import)
├── UITestHelpers.swift          # Page Objects para suporte
├── TestSkopiaAstroDailyUITests.swift         # Arquivo mínimo
└── LaunchTests.swift  # Teste de screenshot
```

#### **Execução Rápida**
- ⚡ Apenas 4 testes essenciais
- 🎯 Cobertura focada nas funcionalidades críticas
- 🚀 Execução otimizada e rápida
- ✅ Sem redundâncias ou testes desnecessários

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


## 🔧 Pontos de Melhoria

### 📈 Performance
- [ ] **Paginação**: Implementar carregamento incremental na lista
- [ ] **Prefetch**: Pre-carregamento de imagens adjacentes
- [ ] **Sincronização de Dados**: Armazenar resultados das imagens APOD no banco de dados local (Core Data) com sincronização inteligente para evitar requests desnecessários nas consultas por data
- [ ] **Cache Strategy**: Cache de rede mais inteligente
- [ ] **Image Compression**: Otimização automática de imagens

### 🏗️ Arquitetura
- [ ] **Dependency Injection**: Container de DI (Swinject)
- [ ] **Coordinator Pattern**: Navegação centralizada

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

#### API Endpoints Utilizados
- **APOD**: `https://api.nasa.gov/planetary/apod`
- **Rate Limit**: 1000 requests/hora (com API key)