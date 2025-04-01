
# DB Control

DB Control é uma biblioteca em Lua para facilitar o gerenciamento de bancos de dados SQLite no MTA (Multi Theft Auto). Este sistema permite criar, inserir, atualizar, deletar e consultar dados de forma simples e organizada.

## Instalação
Basta incluir o script no seu projeto MTA e chamar a função `Database:new("arquivo.db")` para inicializar a conexão com o banco de dados.

## Funcionalidades

### Criando uma instância do banco de dados
```lua
local db = Database:new("meubanco.db") -- Retorna uma instancia
```
- **`storage`**: Caminho do arquivo de banco de dados SQLite. Pode ser um caminho relativo ou absoluto.

Isso cria uma nova conexão SQLite usando o arquivo `meubanco.db`.

### Criar tabelas (`set`)
```lua
db:set({
    usuarios = {
        id = { type = "INTEGER", primaryKey = true, autoIncrement = true },
        nome = { type = "TEXT", null = false },
        idade = { type = "INTEGER", default = 18 }
    }
})
```
- **`structures`**: Tabela que define a estrutura das tabelas do banco de dados. Cada chave é o nome da tabela e o valor é uma tabela que define as colunas e atributos das mesmas.

Os atributos das colunas podem ser:
- **`type`**: Tipo da coluna (ex: "TEXT", "INTEGER").
- **`primaryKey`**: (opcional) Define se a coluna é chave primária.
- **`autoIncrement`**: (opcional) Define se a coluna deve ter incremento automático.
- **`null`**: (opcional) Define se a coluna pode ser `NULL`.
- **`default`**: (opcional) Define um valor padrão para a coluna.

### Inserir dados (`insert`)
```lua
db:insert("usuarios", { nome = "Carlos", idade = 25 }, function(result)
    print("Inserção realizada:", result)
end)
```
- **`tableName`**: Nome da tabela onde os dados serão inseridos.
- **`data`**: Tabela contendo os dados a serem inseridos. As chaves são os nomes das colunas e os valores são os dados a serem inseridos.
- **`callback`**: Função opcional que será chamada após a inserção ser concluída. Recebe como argumento o resultado da operação.

| id | nome   | idade |
|----|--------|-------|
| 1  | Carlos | 25    |

### Atualizar dados (`update`)
```lua
db:update("usuarios", { idade = 26 }, { id = 1 }, "AND", function(result)
    print("Atualização realizada:", result)
end)
```
- **`tableName`**: Nome da tabela onde os dados serão atualizados.
- **`data`**: Tabela contendo os dados a serem atualizados. As chaves são os nomes das colunas e os valores são os novos dados.
- **`where`**: Tabela contendo as condições de atualização. As chaves são os nomes das colunas e os valores são os valores para comparar.
- **`_type`**: (opcional) Tipo de operador para as condições. Por padrão é `"AND"`, mas pode ser alterado para `"OR"`.
- **`callback`**: Função opcional que será chamada após a atualização ser concluída. Recebe como argumento o resultado da operação.

| id | nome   | idade |
|----|--------|-------|
| 1  | Carlos | 26    |

### Deletar dados (`delete`)
```lua
db:delete("usuarios", { id = 1 }, "AND", function(result)
    print("Usuário deletado:", result)
end)
```
- **`tableName`**: Nome da tabela onde os dados serão deletados.
- **`where`**: Tabela contendo as condições de deleção. As chaves são os nomes das colunas e os valores são os valores para comparar.
- **`_type`**: (opcional) Tipo de operador para as condições. Por padrão é `"AND"`, mas pode ser alterado para `"OR"`.
- **`callback`**: Função opcional que será chamada após a deleção ser concluída. Recebe como argumento o resultado da operação.


### Buscar dados (`find`)
```lua
db:find("usuarios", { "id", "nome" }, { idade = 26 }, "AND", function(result)
    for _, row in ipairs(result) do
        print(row.id, row.nome)
    end
end)
```
- **`tableName`**: Nome da tabela onde os dados serão buscados.
- **`columns`**: Tabela com os nomes das colunas que você deseja recuperar. Se você quiser todas as colunas, use `*`.
- **`where`**: Tabela contendo as condições de busca. As chaves são os nomes das colunas e os valores são os valores para comparar.
- **`_type`**: (opcional) Tipo de operador para as condições. Por padrão é `"AND"`, mas pode ser alterado para `"OR"`.
- **`callback`**: Função opcional que será chamada com o resultado da busca. Recebe como argumentos o resultado da consulta.

| id | nome   |
|----|--------|
| 1  | Carlos |

### Verificar se um registro existe (`exists`)
```lua
db:exists("usuarios", { nome = "Carlos" }, "AND", function(exists, amount)
    print("Existe:", exists, "Total:", amount)
end)
```
- **`tableName`**: Nome da tabela onde a verificação será feita.
- **`where`**: Tabela contendo as condições de verificação. As chaves são os nomes das colunas e os valores são os valores para comparar.
- **`_type`**: (opcional) Tipo de operador para as condições. Por padrão é `"AND"`, mas pode ser alterado para `"OR"`.
- **`callback`**: Função opcional que será chamada com o resultado da verificação. Recebe como argumentos um valor booleano que indica se o registro existe e o número de registros encontrados.

### Sistema de Filas de Consulta
Para evitar problemas de concorrência, as consultas são colocadas em uma fila e executadas sequencialmente.

#### Configurar propriedades do banco (`setProperties`)
```lua
db:setProperties({ queueDelay = 200 })
```
- **`properties`**: Tabela de propriedades que podem ser configuradas. Atualmente, a única propriedade configurável é:
  - **`queueDelay`**: Intervalo (em milissegundos) entre a execução das consultas na fila. O valor padrão é 100.

## Callback
As funções de callback são opcionais, a função retorna os mesmo valores dos argumentos da callback ( apenas `find` e `exists` ).

## Conclusão
O **DB Control** é uma solução eficiente para manipulação de bancos de dados SQLite no MTA, oferecendo suporte para operações assíncronas com callbacks.

Se precisar de mais funcionalidades ou melhorias, contribua no repositório!
