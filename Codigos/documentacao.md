::: mermaid
graph TD
    Cliente --> Sistema
    Sistema --> BancoDeDados
    Sistema --> Backend
    Sistema --> Frontend
    Backend --> API
    Backend --> Serviço
    Frontend --> PáginaWeb
    API --> ClasseA
    API --> ClasseB
    Serviço --> ClasseC
:::

::: mermaid
graph TD
    Cliente --> Sistema
:::
::: mermaid
graph TD
    Sistema --> BancoDeDados
    Sistema --> Backend
    Sistema --> Frontend
:::
::: mermaid
graph TD
    Backend --> API
    Backend --> Serviço
    Frontend --> PáginaWeb
    API --> ClasseA
    API --> ClasseB
    Serviço --> ClasseC
:::
