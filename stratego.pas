{
Trabalho final de MATA37 - Equipe 1: Jean, Luisa e Nanci
Projeto:Combate
}

program stratego;
uses CRT;

type
   no_pecas = ^pecas;
   pecas = record {lista de peças}
              nome    : string[13];
              rank    : integer; {rank da peça - vai de 0 a 11}
              qtde    : integer;
              jogador : integer;
              prox    : no_pecas;
           end;

var
   tabuleiro        : array [1..10, 1..10] of no_pecas;
   controle_pecas   : array [0..11] of integer;
   jog1, jog2, lago : no_pecas;
   confirma         : char;
   opcao            : integer;

{Criação da lista de peças}
procedure lista_pecas(var inicio : no_pecas; nome : string; rank, jogador : integer);
var aux1, aux2 : no_pecas;
begin
   new(aux1);
   aux1^.nome := nome;
   aux1^.rank := rank;
   aux1^.jogador := jogador;
   aux1^.qtde := 0; {quantidade posicionada de peças -> começa com 0}
   aux2 := inicio;
   while (aux2^.prox <> nil) do
      aux2 := aux2^.prox;
   aux2^.prox := aux1;
end; { lista_pecas }

{O procedimento a seguir insere os dados das peças do jogo na lista}
procedure dados_pecas(var inicio : no_pecas; jogador : integer);
begin
   lista_pecas(inicio, 'bandeira', 0, jogador);
   lista_pecas(inicio, 'espiao', 1, jogador);
   lista_pecas(inicio, 'soldado', 2, jogador);
   lista_pecas(inicio, 'cabo-armeiro', 3, jogador);
   lista_pecas(inicio, 'sargento', 4, jogador);
   lista_pecas(inicio, 'tenente', 5, jogador);
   lista_pecas(inicio, 'capitao', 6, jogador);
   lista_pecas(inicio, 'major', 7, jogador);
   lista_pecas(inicio, 'coronel', 8, jogador);
   lista_pecas(inicio, 'general', 9, jogador);
   lista_pecas(inicio, 'marechal', 10, jogador);
   lista_pecas(inicio, 'bomba', 11, jogador);
end; { dados_pecas }

{Procedimento que preenche o vetor de controle com as quantidades máximas de cada peça}
procedure pecas_jogadores;
begin
   controle_pecas[0] := 1;
   controle_pecas[1] := 1;
   controle_pecas[2] := 8;
   controle_pecas[3] := 5;
   controle_pecas[4] := 4;
   controle_pecas[5] := 4;
   controle_pecas[6] := 4;
   controle_pecas[7] := 3;
   controle_pecas[8] := 2;
   controle_pecas[9] := 1;
   controle_pecas[10] := 1;
   controle_pecas[11] := 6;
end; { pecas_jogadores }

{Procedimento para alocar no tabuleiro o lago, que é uma área intransitável}
procedure preenche_lago;
begin
   new(lago);
   lago^.rank := -1;
   lago^.nome := 'lago';
   lago^.jogador := 0;
   tabuleiro[5][3] := lago;
   tabuleiro[5][4] := lago;
   tabuleiro[6][3] := lago;
   tabuleiro[6][4] := lago;
   tabuleiro[5][7] := lago;
   tabuleiro[5][8] := lago;
   tabuleiro[6][7] := lago;
   tabuleiro[6][8] := lago;
end; { preenche_lago }

{Procedimento para impressão do tabuleiro -> recebe o jogador como parâmetro para ocultar as peças do adversário
 Imprime XX para lago e ## para adversário}
procedure imprime_tabuleiro(jogador : integer);
var i, j : integer;
begin
   write('   ');
   for i := 1 to 10 do
   begin
      textcolor(YELLOW);
      write(i:2, ' ');
   end;
   writeln;
   for i := 1 to 10 do
   begin
      textcolor(YELLOW);
      write(i:2, ' ');
      for j := 1 to 10 do
      begin
         if (tabuleiro[i][j] = nil) then
         begin
            textcolor(LIGHTGRAY); {cor dos espacos = cinza claro}
            write('__ ');
         end
         else
            if (tabuleiro[i][j] = lago) then
            begin
               textcolor(GREEN); {cor do lago = verde}
               write('XX ');
            end
            else
               if (tabuleiro[i][j]^.jogador = jogador) then
               begin
                  if (tabuleiro[i][j]^.jogador = 1) then
                     textcolor(BLUE) {cor das peças do jogador 1 = azul}
                  else
                     textcolor(RED); {cor das peças do jogador 2 = vermelho}
                  write(tabuleiro[i][j]^.rank:2, ' ');
               end
               else
               begin
                  if (tabuleiro[i][j]^.jogador = 1) then
                     textcolor(BLUE) {cor das peças do jogador 1 = azul}
                  else
                     textcolor(RED); {cor das peças do jogador 2 = vermelho}
                  write('## ');
               end;
      end;
      writeln;
   end;
end; { imprime_tabuleiro }

{Função para localizar o rank na lista, se ele for válido}
function acha_rank(inicio : no_pecas; rank : integer): no_pecas;
var aux : no_pecas;
begin
   aux := inicio^.prox;
   while (aux^.rank <> rank) and (aux <> nil) do
   begin
      aux := aux^.prox;
   end;
   acha_rank := aux;
end;

{Procedimento para dispor as peças de determinado jogador no tabuleiro}
procedure dispor_pecas(jogador : integer; inicio : no_pecas);
var qtde, linha, coluna, rank : integer;
   checagem                   : boolean;
   aux                        : no_pecas;
begin
   qtde := 0; {Quantidade de peças dispostas... inicia com 0}
   repeat
      writeln('Digite o rank de uma peça. Use 11 para bomba e 0 para bandeira');
      readln(rank);
      aux := acha_rank(inicio, rank);
      {Se o jogador digitar um rank inválido ele terá que digitar novamente}
      while (aux = nil) or (aux^.qtde >= controle_pecas[rank]) do
      begin
         writeln('Peça indisponível. Por favor, digite novamente o rank');
         readln(rank);
         aux := acha_rank(inicio, rank);
      end;
      checagem := false; {Variável para verificar se o jogador digitou uma posição válida no tabuleiro}
      repeat
         writeln('Digite a posição da peça');
         readln(linha, coluna);
         if (aux^.jogador = 1) then
         begin
            if (linha < 0) or (linha > 4) or (tabuleiro[linha][coluna] <> nil) then
               writeln('Posição inválida')
            else
               checagem := true;
         end
         else
            if (linha > 10) or (linha < 7) or (tabuleiro[linha][coluna] <> nil) then
               writeln('Posição inválida')
            else
               checagem := true;
      until (checagem = true);
      tabuleiro[linha][coluna] := aux;
      inc(aux^.qtde); {Incrementa o número de peças já alocadas na lista do jogador}
      inc(qtde);
      imprime_tabuleiro(jogador);
      writeln;
   until (qtde = 40);
end; { dispor_pecas }

procedure remove_peca(peca : no_pecas);
begin
   {Decrementa o vetor que diz a quantidade de cada peça}
   dec(peca^.qtde);
end; { remove_peca }

{
Função de combate: ela checa qual peça ganha no combate direto
Valores de retorno:
0 para empate -> exclusão das duas peças
1 para vitória do atacante -> exclusão do atacado
-1 para vitória do atacado -> exclusão do atacante
}
function combate(linha1, coluna1, linha2, coluna2 : integer) : integer;
var atacante, atacado : no_pecas;
begin
   atacante := tabuleiro[linha1][coluna1];
   atacado := tabuleiro[linha2][coluna2];
   {Exceção 1: cabo-armeiro desarma a bomba}
   if (atacante^.rank = 3) and (atacado^.rank = 11) then
   begin
      remove_peca(atacado);
      tabuleiro[linha2][coluna2] := tabuleiro[linha1][coluna1];
      combate := 1;
      writeln('Bomba desarmada com sucesso!');
      writeln;
   end
   else
      {Exceção 2: se o espião atacar o marechal ele ganha}
      if (atacante^.rank = 1) and (atacado^.rank = 10) then
      begin
         remove_peca(atacado);
         tabuleiro[linha2][coluna2] := tabuleiro[linha1][coluna1];
         combate := 1;
         writeln('O espião derrotou o marechal');
         writeln;
      end
      else
         {Regra: ganha quem tiver maior rank}
         if (atacante^.rank > atacado^.rank) then
         begin
            remove_peca(atacado);
            tabuleiro[linha2][coluna2] := tabuleiro[linha1][coluna1];
            combate := 1;
            writeln('O ', atacante^.nome, 'derrotou o ', atacado^.nome);
            writeln;
         end
         else
            if (atacante^.rank = atacado^.rank) then
            begin
               remove_peca(atacado);
               remove_peca(atacante);
               tabuleiro[linha2][coluna2] := nil;
               combate:=0;
               writeln('As duas peças são de mesmo rank, portanto o combate deu empate. Ambas as peças foram retiradas do jogo.');
               writeln;
            end
            else
            begin
               remove_peca(atacante);
               combate:=-1;
               writeln('O ', atacado^.nome, ' derrotou o ', atacante^.nome);
               writeln;
            end;
   {O lugar da peça atacante sempre vai ficar vazio -> ou ela toma outro lugar ou ela é derrotada}
   tabuleiro[linha1][coluna1] := nil;
end; { combate }

{Procedimento para exibição de erro}
procedure erros(erro : integer);
begin
   case erro of
     1 : writeln('Espaço vazio. Por favor, tente novamente.');
     2 : writeln('Peça inválida. Por favor, tente novamente.');
     3 : writeln('Peça imóvel. Por favor, tente novamente.');
     4 : writeln('Esta peça não pode se mover. Por favor, tente novamente.');
   end;
end; { erros }

{Função para verificar se determinado espaço está no tabuleiro}
function no_tabuleiro(linha, coluna : integer ): boolean;
begin
   no_tabuleiro := (linha > 0) and (linha <= 10) and (coluna > 0) and (coluna <= 10)
end; { no_tabuleiro }

{Funçao verifica se a peça que o jogador escolheu para mover é válida
 recebe um boolean para verificar se imprime ou não o erro}
function valida_espaco(jogador, linha, coluna : integer; exibe : boolean): boolean;
var
   adversario : integer;
   aux        : boolean ;
begin
   aux := false;
   adversario := (jogador mod 2) + 1;
   {1. espaço vazio}
   if (tabuleiro[linha][coluna] = nil) then
   begin
      if (exibe) then erros(1)
   end
   else
      {2. verifica se a peça é do próprio jogador}
      if (tabuleiro[linha][coluna]^.jogador <> jogador) then
      begin
         if (exibe) then erros(2)
      end
      else
         {3. verifica se a peça selecionada é móvel}
         if (tabuleiro[linha][coluna]^.rank = 0) or (tabuleiro[linha][coluna]^.rank = 11) then
         begin
            if (exibe) then erros(3);
         end
         else

            {4. Verifica se a peça está livre pra se movimentar}
            if ((not no_tabuleiro(linha, coluna+1) or ((tabuleiro[linha][coluna+1] <> nil) and (tabuleiro[linha][coluna+1]^.jogador <> adversario))) and
                (not no_tabuleiro(linha, coluna-1) or ((tabuleiro[linha][coluna-1] <> nil) and (tabuleiro[linha][coluna-1]^.jogador <> adversario))) and
                (not no_tabuleiro(linha+1, coluna) or ((tabuleiro[linha+1][coluna] <> nil) and (tabuleiro[linha+1][coluna]^.jogador <> adversario))) and
                (not no_tabuleiro(linha-1, coluna) or ((tabuleiro[linha-1][coluna] <> nil) and (tabuleiro[linha-1][coluna]^.jogador <> adversario)))) then
            begin
               if (exibe) then erros(4);
            end
            else
               aux := true;
   valida_espaco := aux;
end; { valida_espaco }

{Função para ordenar 2 inteiros}
procedure ordena(var int1, int2 : integer);
var
   aux : integer;
begin
   if (int1 > int2) then
   begin
      aux := int1;
      int1 := int2;
      int2 := aux;
   end;
end; { ordena }

{Função verifica se o movimento das peças é válido}
function valida_movimento(linha_atual, coluna_atual, linha, coluna : integer) : boolean;
var aux : boolean;
   rank : integer;
begin
   aux := false;
   rank := tabuleiro[linha_atual][coluna_atual]^.rank;

   {Está dentro do tabuleiro?}
   if (no_tabuleiro(linha, coluna)) then
   begin
      {Regra de movimento: 1 casa horizontal ou vertical}
      if ((linha = linha_atual + 1) and (coluna = coluna_atual)) or ((linha = linha_atual -1) and
         (coluna = coluna_atual)) or ((coluna = coluna_atual + 1) and (linha = linha_atual)) or
         ((coluna = coluna_atual - 1) and (linha = linha_atual)) then
         aux := true;
      {O 2 pode se mover mais de uma casa, mas não pode atacar se fizer isso
       Não pode ter ninguém no caminho do ataque}
      if (rank = 2) then
      begin
         if (linha = linha_atual) then
         begin
            {Se o lugar de destino estiver vazio ele checa se o caminho todo esta vazio para não "pular" peça}
            if (tabuleiro[linha][coluna] = nil) then
            begin
               ordena(coluna_atual, coluna);
               aux := true;
               inc(coluna_atual);
               while (coluna_atual < coluna) do
               begin
                  if (tabuleiro[linha][coluna_atual] <> nil) then
                     aux := false;
                  inc(coluna_atual);
               end;
            end;
         end
         else
            if (coluna = coluna_atual) then
            begin
               {Se o lugar de destino estiver vazio ele checa se o caminho todo esta vazio para não "pular" peça}
               if (tabuleiro[linha][coluna] = nil) then
               begin
                  ordena(linha_atual, linha);
                  aux := true;
                  inc(linha_atual);
                  while (linha_atual < linha) do
                  begin
                     if (tabuleiro[linha_atual][coluna] <> nil) then
                        aux := false;
                     inc(linha_atual);
                  end;
               end;
            end;
      end;
   end;
   valida_movimento := aux;
end; { valida_movimento }

{Procedimento para cuidar dos movimentos das peças -> linha_atual e coluna_atual são as coordenadas da peça
 j é o inteiro que representa o jogador 1 ou 2, linha e coluna são as coordenadas que o jogador pretende mover a peça}
function move_peca(jogador, linha_atual, coluna_atual, linha, coluna : integer):boolean;
begin
   {Verifica se é possível o movimento}
   move_peca := valida_movimento(linha_atual, coluna_atual, linha, coluna);
   if (move_peca) then
   begin
      {Se o lugar estiver vazio...}
      if (tabuleiro[linha][coluna] = nil) then
      begin
         tabuleiro[linha][coluna] := tabuleiro[linha_atual][coluna_atual];
         tabuleiro[linha_atual][coluna_atual] := nil;
      end
      else
         {São peças do mesmo jogador?}
         if (tabuleiro[linha_atual][coluna_atual]^.jogador <> tabuleiro[linha][coluna]^.jogador) then
         begin
            if (tabuleiro[linha][coluna] = lago) then
            begin
               writeln('Área intransitável. Por favor, tente novamente.');
               move_peca := false;
            end
            else
               combate(linha_atual, coluna_atual, linha, coluna);
         end
         else
         begin
            writeln('Peças do mesmo jogador. Por favor, tente novamente.');
            move_peca := false;
         end;
   end
   else
      writeln('Movimento inválido. Por favor, tente novamente.');
end;
{ move_peca }

{Função para contar as peças móveis do jogador -> recebe o ponteiro inicial da lista do jogador correspondente}
function conta_pecas (inicio : no_pecas) : integer;
var cont  : integer;
   aux : no_pecas;
begin
   cont := 0;
   aux := inicio^.prox;
   while (aux <> nil) do
   begin
      if (aux^.rank > 0) and (aux^.rank <= 10) then
         cont := cont + aux^.qtde;
      aux := aux^.prox;
   end;
   conta_pecas := cont;
end; { conta_pecas }

{Verifica em todo o tabuleiro se as peças do jogador parâmetro podem se mover;
 a qtde se refere ao número de peças móveis restantes}
function pode_mover(jogador : no_pecas; qtde : integer) : boolean;
var
   i, j        : integer;
   nenhum_move : boolean;
   aux         : no_pecas;
begin
   i := 1;
   nenhum_move := true;
   while (nenhum_move) and (qtde > 0) and (i <= 10) do
   begin
      j := 1;
      while (nenhum_move) and (qtde > 0) and (j <= 10) do
      begin
         aux := tabuleiro[i][j];
         { Verifica que existe peça e é do jogador em questão }
         if (aux <> nil) and (valida_espaco(jogador^.jogador, i, j, false)) and (aux^.rank <> 0) then
         begin
            { Verifica se a peça pode se mover em alguma direção. Vale mesmo para o caso do
            soldado. A função valida_movimento já verifica se for passado algum valor fora do tabuleiro}
            if (valida_movimento(i, j, i, j + 1)) or (valida_movimento(i, j, i + 1, j)) or
               (valida_movimento(i, j, i - 1, j)) or (valida_movimento(i, j, i, j - 1)) then
               nenhum_move := false;
            { Decrementa o número de peças do jogador que falta serem verificadas }
            dec(qtde);
         end;
         inc(j);
      end;
      inc(i);
   end;

   pode_mover := not nenhum_move;
end; { pode_mover }

{Função verifica se o jogo terminou}

function final_jogo(jogador : integer ): boolean;
var aux   : boolean;
   cont   : integer;
   inicio : no_pecas;
begin
   aux := false;
   cont := 0;
   {1. verificar na lista adversária se existe a bandeira}
   if (jogador = 1) then
      inicio := jog2^.prox
   else
      inicio := jog1^.prox;
   while (inicio^.rank <> 0) do
      inicio := inicio^.prox;
   if (inicio^.qtde = 0) then
   begin
      aux := true;
      writeln('Vitória do jogador ', jogador);
      writeln;
   end;
   {2. checar peças móveis dos dois jogadores}
   cont := conta_pecas(jog1);
   {6 é o número máximo de peças que podem ficar imóveis no jogo, portanto só vale a pena verificar a partir dele}
   if (cont <= 6) then
      if (not pode_mover(jog1, cont)) then
      begin
         aux := true;
         writeln('Vitória do jogador 2');
         writeln;
      end;
   cont := conta_pecas(jog2);
   if (cont <= 6) then
      if (not pode_mover(jog2, cont)) then
      begin
         aux := true;
         writeln('Vitória do jogador 1');
         writeln;
      end;
   final_jogo := aux;
end; { final_jogo }

{PROCEDIMENTOS DE OPÇÃO PARA OS JOGADORES}
procedure blitzkrieg (inicio : no_pecas; jogador : integer);
var
   aux, bandeira, espiao, soldado, cabo, sargento, tenente, capitao, major, coronel, general, marechal, bomba : no_pecas;

begin
   aux := inicio^.prox;
   while (aux <> nil) do
   begin
      aux^.qtde := controle_pecas[aux^.rank];
      aux := aux^.prox;
   end;
   bandeira:= inicio^.prox;
   espiao:= bandeira^.prox;
   soldado:= espiao^.prox;
   cabo:= soldado^.prox;
   sargento:= cabo^.prox;
   tenente:= sargento^.prox;
   capitao:= tenente^.prox;
   major:= capitao^.prox;
   coronel:= major^.prox;
   general:= coronel^.prox;
   marechal:= general^.prox;
   bomba:= marechal^.prox;

   if (jogador=1) then
   begin
      tabuleiro[1][1] :=    soldado;
      tabuleiro[1][2] := 	coronel;
      tabuleiro[1][3] :=	capitao;
      tabuleiro[1][4] :=	sargento;
      tabuleiro[1][5] :=	marechal;
      tabuleiro[1][6] :=	general;
      tabuleiro[1][7] :=	capitao;
      tabuleiro[1][8] :=	tenente;
      tabuleiro[1][9] :=	coronel;
      tabuleiro[1][10] :=   cabo;
      tabuleiro[2][1] :=	tenente;
      tabuleiro[2][2] :=	cabo;
      tabuleiro[2][3] :=	cabo;
      tabuleiro[2][4] :=	soldado;
      tabuleiro[2][5] :=	bomba;
      tabuleiro[2][6] :=	soldado;
      tabuleiro[2][7] :=	capitao;
      tabuleiro[2][8] :=	soldado;
      tabuleiro[2][9] :=	major;
      tabuleiro[2][10] :=	bomba;
      tabuleiro[3][1] :=	major;
      tabuleiro[3][2] :=	soldado;
      tabuleiro[3][3] :=	bomba;
      tabuleiro[3][4] :=	soldado;
      tabuleiro[3][5] :=	major;
      tabuleiro[3][6] :=	cabo;
      tabuleiro[3][7] :=	sargento;
      tabuleiro[3][8] :=	bomba;
      tabuleiro[3][9] :=	espiao;
      tabuleiro[3][10] :=	tenente;
      tabuleiro[4][1] :=	soldado;
      tabuleiro[4][2] :=	bomba;
      tabuleiro[4][3] :=	bandeira;
      tabuleiro[4][4] :=	bomba;
      tabuleiro[4][5] :=	capitao;
      tabuleiro[4][6] :=	cabo;
      tabuleiro[4][7] :=	soldado;
      tabuleiro[4][8] :=	tenente;
      tabuleiro[4][9] :=	sargento;
      tabuleiro[4][10] :=	sargento;
   end
   else
   begin
      tabuleiro[7][1] :=	soldado;
      tabuleiro[7][2] :=	coronel;
      tabuleiro[7][3] :=	capitao;
      tabuleiro[7][4] :=	sargento;
      tabuleiro[7][5] :=	marechal;
      tabuleiro[7][6] :=	general;
      tabuleiro[7][7] :=	capitao;
      tabuleiro[7][8] :=	tenente;
      tabuleiro[7][9] :=	coronel;
      tabuleiro[7][10] :=	cabo;
      tabuleiro[8][1] :=	tenente;
      tabuleiro[8][2] :=	cabo;
      tabuleiro[8][3] :=	cabo;
      tabuleiro[8][4] :=	soldado;
      tabuleiro[8][5] :=	bomba;
      tabuleiro[8][6] :=	soldado;
      tabuleiro[8][7] :=	capitao;
      tabuleiro[8][8] :=	soldado;
      tabuleiro[8][9] :=	major;
      tabuleiro[8][10] :=	bomba;
      tabuleiro[9][1] :=	major;
      tabuleiro[9][2] :=	soldado;
      tabuleiro[9][3] :=	bomba;
      tabuleiro[9][4] :=	soldado;
      tabuleiro[9][5] :=	major;
      tabuleiro[9][6] :=	cabo;
      tabuleiro[9][7] :=	sargento;
      tabuleiro[9][8] :=	bomba;
      tabuleiro[9][9] :=	espiao;
      tabuleiro[9][10] :=	tenente;
      tabuleiro[10][1] :=	soldado;
      tabuleiro[10][2] :=	bomba;
      tabuleiro[10][3] :=	bandeira;
      tabuleiro[10][4] :=	bomba;
      tabuleiro[10][5] :=	capitao;
      tabuleiro[10][6] :=	cabo;
      tabuleiro[10][7] :=	soldado;
      tabuleiro[10][8] :=	tenente;
      tabuleiro[10][9] :=	sargento;
      tabuleiro[10][10] :=	sargento;
   end;
   imprime_tabuleiro(jogador);
end; { blitzkrieg }

procedure tempest_defense (inicio : no_pecas; jogador : integer);
var
   aux, bandeira, espiao, soldado, cabo, sargento, tenente, capitao, major, coronel, general, marechal, bomba : no_pecas;

begin
   aux := inicio^.prox;
   while (aux <> nil) do
   begin
      aux^.qtde := controle_pecas[aux^.rank];
      aux := aux^.prox;
   end;
   bandeira:= inicio^.prox;
   espiao:= bandeira^.prox;
   soldado:= espiao^.prox;
   cabo:= soldado^.prox;
   sargento:= cabo^.prox;
   tenente:= sargento^.prox;
   capitao:= tenente^.prox;
   major:= capitao^.prox;
   coronel:= major^.prox;
   general:= coronel^.prox;
   marechal:= general^.prox;
   bomba:= marechal^.prox;

   if (jogador=1) then
   begin
      tabuleiro[1][1] :=	soldado;
      tabuleiro[1][2] := 	major;
      tabuleiro[1][3] :=	general;
      tabuleiro[1][4] :=	capitao;
      tabuleiro[1][5] :=	soldado;
      tabuleiro[1][6] :=	sargento;
      tabuleiro[1][7] :=	capitao;
      tabuleiro[1][8] :=	soldado;
      tabuleiro[1][9] :=	coronel;
      tabuleiro[1][10] :=	sargento;
      tabuleiro[2][1] :=	bomba;
      tabuleiro[2][2] :=	soldado;
      tabuleiro[2][3] :=	soldado;
      tabuleiro[2][4] :=	cabo;
      tabuleiro[2][5] :=	coronel;
      tabuleiro[2][6] :=	capitao;
      tabuleiro[2][7] :=	tenente;
      tabuleiro[2][8] :=	cabo;
      tabuleiro[2][9] :=	marechal;
      tabuleiro[2][10] :=	soldado;
      tabuleiro[3][1] :=	major;
      tabuleiro[3][2] :=	bomba;
      tabuleiro[3][3] :=	tenente;
      tabuleiro[3][4] :=	bomba;
      tabuleiro[3][5] :=	capitao;
      tabuleiro[3][6] :=	cabo;
      tabuleiro[3][7] :=	bomba;
      tabuleiro[3][8] :=	espiao;
      tabuleiro[3][9] :=	tenente;
      tabuleiro[3][10] :=	sargento;
      tabuleiro[4][1] :=	bomba;
      tabuleiro[4][2] :=	bandeira;
      tabuleiro[4][3] :=	bomba;
      tabuleiro[4][4] :=	sargento;
      tabuleiro[4][5] :=	soldado;
      tabuleiro[4][6] :=	tenente;
      tabuleiro[4][7] :=	cabo;
      tabuleiro[4][8] :=	soldado;
      tabuleiro[4][9] :=	cabo;
      tabuleiro[4][10] :=	major;
   end
   else
   begin
      tabuleiro[7][1] :=	soldado;
      tabuleiro[7][2] :=	major;
      tabuleiro[7][3] :=	general;
      tabuleiro[7][4] :=	capitao;
      tabuleiro[7][5] :=	soldado;
      tabuleiro[7][6] :=	sargento;
      tabuleiro[7][7] :=	capitao;
      tabuleiro[7][8] :=	soldado;
      tabuleiro[7][9] :=	coronel;
      tabuleiro[7][10] :=	sargento;
      tabuleiro[8][1] :=	bomba;
      tabuleiro[8][2] :=	soldado;
      tabuleiro[8][3] :=	soldado;
      tabuleiro[8][4] :=	cabo;
      tabuleiro[8][5] :=	coronel;
      tabuleiro[8][6] :=	capitao;
      tabuleiro[8][7] :=	tenente;
      tabuleiro[8][8] :=	cabo;
      tabuleiro[8][9] :=	marechal;
      tabuleiro[8][10] :=	soldado;
      tabuleiro[9][1] :=	major;
      tabuleiro[9][2] :=	bomba;
      tabuleiro[9][3] :=	tenente;
      tabuleiro[9][4] :=	bomba;
      tabuleiro[9][5] :=	capitao;
      tabuleiro[9][6] :=	cabo;
      tabuleiro[9][7] :=	bomba;
      tabuleiro[9][8] :=	espiao;
      tabuleiro[9][9] :=	tenente;
      tabuleiro[9][10] :=	sargento;
      tabuleiro[10][1] :=	bomba;
      tabuleiro[10][2] :=	bandeira;
      tabuleiro[10][3] :=	bomba;
      tabuleiro[10][4] :=	sargento;
      tabuleiro[10][5] :=	soldado;
      tabuleiro[10][6] :=	tenente;
      tabuleiro[10][7] :=	cabo;
      tabuleiro[10][8] :=	soldado;
      tabuleiro[10][9] :=	cabo;
      tabuleiro[10][10] :=	major;
   end;
   imprime_tabuleiro(jogador);
end; { tempest_defense }

procedure wheel_danger (inicio : no_pecas; jogador : integer);
var
   aux, bandeira, espiao, soldado, cabo, sargento, tenente, capitao, major, coronel, general, marechal, bomba : no_pecas;

begin
   aux := inicio^.prox;
   while (aux <> nil) do
   begin
      aux^.qtde := controle_pecas[aux^.rank];
      aux := aux^.prox;
   end;
   bandeira:= inicio^.prox;
   espiao:= bandeira^.prox;
   soldado:= espiao^.prox;
   cabo:= soldado^.prox;
   sargento:= cabo^.prox;
   tenente:= sargento^.prox;
   capitao:= tenente^.prox;
   major:= capitao^.prox;
   coronel:= major^.prox;
   general:= coronel^.prox;
   marechal:= general^.prox;
   bomba:= marechal^.prox;

   if (jogador=1) then
   begin
      tabuleiro[1][1] :=	soldado;
      tabuleiro[1][2] := 	soldado;
      tabuleiro[1][3] :=	cabo;
      tabuleiro[1][4] :=	major;
      tabuleiro[1][5] :=	soldado;
      tabuleiro[1][6] :=	soldado;
      tabuleiro[1][7] :=	general;
      tabuleiro[1][8] :=	soldado;
      tabuleiro[1][9] :=	cabo;
      tabuleiro[1][10] :=	soldado;
      tabuleiro[2][1] :=	tenente;
      tabuleiro[2][2] :=	bomba;
      tabuleiro[2][3] :=	sargento;
      tabuleiro[2][4] :=	tenente;
      tabuleiro[2][5] :=	bomba;
      tabuleiro[2][6] :=	tenente;
      tabuleiro[2][7] :=	capitao;
      tabuleiro[2][8] :=	bomba;
      tabuleiro[2][9] :=	tenente;
      tabuleiro[2][10] :=	major;
      tabuleiro[3][1] :=	capitao;
      tabuleiro[3][2] :=	coronel;
      tabuleiro[3][3] :=	marechal;
      tabuleiro[3][4] :=	bomba;
      tabuleiro[3][5] :=	bandeira;
      tabuleiro[3][6] :=	bomba;
      tabuleiro[3][7] :=	capitao;
      tabuleiro[3][8] :=	cabo;
      tabuleiro[3][9] :=	sargento;
      tabuleiro[3][10] :=	capitao;
      tabuleiro[4][1] :=	sargento;
      tabuleiro[4][2] :=	soldado;
      tabuleiro[4][3] :=	sargento;
      tabuleiro[4][4] :=	cabo;
      tabuleiro[4][5] :=	bomba;
      tabuleiro[4][6] :=	major;
      tabuleiro[4][7] :=	coronel;
      tabuleiro[4][8] :=	espiao;
      tabuleiro[4][9] :=	soldado;
      tabuleiro[4][10] :=	cabo;
   end
   else
   begin
      tabuleiro[7][1] :=	soldado;
      tabuleiro[7][2] :=	soldado;
      tabuleiro[7][3] :=	cabo;
      tabuleiro[7][4] :=	major;
      tabuleiro[7][5] :=	soldado;
      tabuleiro[7][6] :=	soldado;
      tabuleiro[7][7] :=	general;
      tabuleiro[7][8] :=	soldado;
      tabuleiro[7][9] :=	cabo;
      tabuleiro[7][10] :=	soldado;
      tabuleiro[8][1] :=	tenente;
      tabuleiro[8][2] :=	bomba;
      tabuleiro[8][3] :=	sargento;
      tabuleiro[8][4] :=	tenente;
      tabuleiro[8][5] :=	bomba;
      tabuleiro[8][6] :=	tenente;
      tabuleiro[8][7] :=	capitao;
      tabuleiro[8][8] :=	bomba;
      tabuleiro[8][9] :=	tenente;
      tabuleiro[8][10] :=	major;
      tabuleiro[9][1] :=	capitao;
      tabuleiro[9][2] :=	coronel;
      tabuleiro[9][3] :=	marechal;
      tabuleiro[9][4] :=	bomba;
      tabuleiro[9][5] :=	bandeira;
      tabuleiro[9][6] :=	bomba;
      tabuleiro[9][7] :=	capitao;
      tabuleiro[9][8] :=	cabo;
      tabuleiro[9][9] :=	sargento;
      tabuleiro[9][10] :=	capitao;
      tabuleiro[10][1] :=	sargento;
      tabuleiro[10][2] :=	soldado;
      tabuleiro[10][3] :=	sargento;
      tabuleiro[10][4] :=	cabo;
      tabuleiro[10][5] :=	bomba;
      tabuleiro[10][6] :=	major;
      tabuleiro[10][7] :=	coronel;
      tabuleiro[10][8] :=	espiao;
      tabuleiro[10][9] :=	soldado;
      tabuleiro[10][10] :=	cabo;
   end;
   imprime_tabuleiro(jogador);
end; { wheel_danger }

procedure corner_fortress (inicio : no_pecas; jogador : integer);
var
   aux, bandeira, espiao, soldado, cabo, sargento, tenente, capitao, major, coronel, general, marechal, bomba : no_pecas;

begin
   aux := inicio^.prox;
   while (aux <> nil) do
   begin
      aux^.qtde := controle_pecas[aux^.rank];
      aux := aux^.prox;
   end;
   bandeira:= inicio^.prox;
   espiao:= bandeira^.prox;
   soldado:= espiao^.prox;
   cabo:= soldado^.prox;
   sargento:= cabo^.prox;
   tenente:= sargento^.prox;
   capitao:= tenente^.prox;
   major:= capitao^.prox;
   coronel:= major^.prox;
   general:= coronel^.prox;
   marechal:= general^.prox;
   bomba:= marechal^.prox;

   if (jogador=1) then
   begin
      tabuleiro[1][1] :=	capitao;
      tabuleiro[1][2] := 	soldado;
      tabuleiro[1][3] :=	general;
      tabuleiro[1][4] :=	tenente;
      tabuleiro[1][5] :=	soldado;
      tabuleiro[1][6] :=	coronel;
      tabuleiro[1][7] :=	soldado;
      tabuleiro[1][8] :=	sargento;
      tabuleiro[1][9] :=	tenente;
      tabuleiro[1][10] :=	soldado;
      tabuleiro[2][1] :=	bomba;
      tabuleiro[2][2] :=	soldado;
      tabuleiro[2][3] :=	major;
      tabuleiro[2][4] :=	capitao;
      tabuleiro[2][5] :=	soldado;
      tabuleiro[2][6] :=	soldado;
      tabuleiro[2][7] :=	cabo;
      tabuleiro[2][8] :=	marechal;
      tabuleiro[2][9] :=	cabo;
      tabuleiro[2][10] :=	major;
      tabuleiro[3][1] :=	sargento;
      tabuleiro[3][2] :=	bomba;
      tabuleiro[3][3] :=	coronel;
      tabuleiro[3][4] :=	tenente;
      tabuleiro[3][5] :=	bomba;
      tabuleiro[3][6] :=	capitao;
      tabuleiro[3][7] :=	espiao;
      tabuleiro[3][8] :=	bomba;
      tabuleiro[3][9] :=	soldado;
      tabuleiro[3][10] :=	cabo;
      tabuleiro[4][1] :=	bandeira;
      tabuleiro[4][2] :=	sargento;
      tabuleiro[4][3] :=	bomba;
      tabuleiro[4][4] :=	major;
      tabuleiro[4][5] :=	cabo;
      tabuleiro[4][6] :=	sargento;
      tabuleiro[4][7] :=	capitao;
      tabuleiro[4][8] :=	cabo;
      tabuleiro[4][9] :=	tenente;
      tabuleiro[4][10] :=	bomba;
   end
   else
   begin
      tabuleiro[7][1] :=	capitao;
      tabuleiro[7][2] :=	soldado;
      tabuleiro[7][3] :=	general;
      tabuleiro[7][4] :=	tenente;
      tabuleiro[7][5] :=	soldado;
      tabuleiro[7][6] :=	coronel;
      tabuleiro[7][7] :=	soldado;
      tabuleiro[7][8] :=	sargento;
      tabuleiro[7][9] :=	tenente;
      tabuleiro[7][10] :=	soldado;
      tabuleiro[8][1] :=	bomba;
      tabuleiro[8][2] :=	soldado;
      tabuleiro[8][3] :=	major;
      tabuleiro[8][4] :=	capitao;
      tabuleiro[8][5] :=	soldado;
      tabuleiro[8][6] :=	soldado;
      tabuleiro[8][7] :=	cabo;
      tabuleiro[8][8] :=	marechal;
      tabuleiro[8][9] :=	cabo;
      tabuleiro[8][10] :=	major;
      tabuleiro[9][1] :=	sargento;
      tabuleiro[9][2] :=	bomba;
      tabuleiro[9][3] :=	coronel;
      tabuleiro[9][4] :=	tenente;
      tabuleiro[9][5] :=	bomba;
      tabuleiro[9][6] :=	capitao;
      tabuleiro[9][7] :=	espiao;
      tabuleiro[9][8] :=	bomba;
      tabuleiro[9][9] :=	soldado;
      tabuleiro[9][10] :=	cabo;
      tabuleiro[10][1] :=	bandeira;
      tabuleiro[10][2] :=	sargento;
      tabuleiro[10][3] :=	bomba;
      tabuleiro[10][4] :=	major;
      tabuleiro[10][5] :=	cabo;
      tabuleiro[10][6] :=	sargento;
      tabuleiro[10][7] :=	capitao;
      tabuleiro[10][8] :=	cabo;
      tabuleiro[10][9] :=	tenente;
      tabuleiro[10][10] :=	bomba;
   end;
   imprime_tabuleiro(jogador);
end; { corner_fortress }

procedure corner_blitz (inicio : no_pecas; jogador : integer);
var
   aux, bandeira, espiao, soldado, cabo, sargento, tenente, capitao, major, coronel, general, marechal, bomba : no_pecas;

begin
   aux := inicio^.prox;
   while (aux <> nil) do
   begin
      aux^.qtde := controle_pecas[aux^.rank];
      aux := aux^.prox;
   end;
   bandeira:= inicio^.prox;
   espiao:= bandeira^.prox;
   soldado:= espiao^.prox;
   cabo:= soldado^.prox;
   sargento:= cabo^.prox;
   tenente:= sargento^.prox;
   capitao:= tenente^.prox;
   major:= capitao^.prox;
   coronel:= major^.prox;
   general:= coronel^.prox;
   marechal:= general^.prox;
   bomba:= marechal^.prox;

      if (jogador=1) then
   begin
      tabuleiro[1][1] :=	soldado;
      tabuleiro[1][2] :=	tenente;
      tabuleiro[1][3] :=	general;
      tabuleiro[1][4] :=	capitao;
      tabuleiro[1][5] :=	soldado;
      tabuleiro[1][6] :=	tenente;
      tabuleiro[1][7] :=	capitao;
      tabuleiro[1][8] :=	coronel;
      tabuleiro[1][9] :=	sargento;
      tabuleiro[1][10] :=	soldado;
      tabuleiro[2][1] :=	tenente;
      tabuleiro[2][2] :=	soldado;
      tabuleiro[2][3] :=	capitao;
      tabuleiro[2][4] :=	coronel;
      tabuleiro[2][5] :=	major;
      tabuleiro[2][6] :=	soldado;
      tabuleiro[2][7] :=	soldado;
      tabuleiro[2][8] :=	cabo;
      tabuleiro[2][9] :=	bomba;
      tabuleiro[2][10] :=	marechal;
      tabuleiro[3][1] :=	bomba;
      tabuleiro[3][2] :=	major;
      tabuleiro[3][3] :=	sargento;
      tabuleiro[3][4] :=	major;
      tabuleiro[3][5] :=	espiao;
      tabuleiro[3][6] :=	cabo;
      tabuleiro[3][7] :=	sargento;
      tabuleiro[3][8] :=	tenente;
      tabuleiro[3][9] :=	capitao;
      tabuleiro[3][10] :=	cabo;
      tabuleiro[4][1] :=	bandeira;
      tabuleiro[4][2] :=	bomba;
      tabuleiro[4][3] :=	soldado;
      tabuleiro[4][4] :=	bomba;
      tabuleiro[4][5] :=	cabo;
      tabuleiro[4][6] :=	sargento;
      tabuleiro[4][7] :=	bomba;
      tabuleiro[4][8] :=	soldado;
      tabuleiro[4][9] :=	bomba;
      tabuleiro[4][10] :=	cabo;
   end
   else
   begin
      tabuleiro[7][1] :=	soldado;
      tabuleiro[7][2] :=	tenente;
      tabuleiro[7][3] :=	general;
      tabuleiro[7][4] :=	capitao;
      tabuleiro[7][5] :=	soldado;
      tabuleiro[7][6] :=	tenente;
      tabuleiro[7][7] :=	capitao;
      tabuleiro[7][8] :=	coronel;
      tabuleiro[7][9] :=	sargento;
      tabuleiro[7][10] :=	soldado;
      tabuleiro[8][1] :=	tenente;
      tabuleiro[8][2] :=	soldado;
      tabuleiro[8][3] :=	capitao;
      tabuleiro[8][4] :=	coronel;
      tabuleiro[8][5] :=	major;
      tabuleiro[8][6] :=	soldado;
      tabuleiro[8][7] :=	soldado;
      tabuleiro[8][8] :=	cabo;
      tabuleiro[8][9] :=	bomba;
      tabuleiro[8][10] :=	marechal;
      tabuleiro[9][1] :=	bomba;
      tabuleiro[9][2] :=	major;
      tabuleiro[9][3] :=	sargento;
      tabuleiro[9][4] :=	major;
      tabuleiro[9][5] :=	espiao;
      tabuleiro[9][6] :=	cabo;
      tabuleiro[9][7] :=	sargento;
      tabuleiro[9][8] :=	tenente;
      tabuleiro[9][9] :=	capitao;
      tabuleiro[9][10] :=	cabo;
      tabuleiro[10][1] :=	bandeira;
      tabuleiro[10][2] :=	bomba;
      tabuleiro[10][3] :=	soldado;
      tabuleiro[10][4] :=	bomba;
      tabuleiro[10][5] :=	cabo;
      tabuleiro[10][6] :=	sargento;
      tabuleiro[10][7] :=	bomba;
      tabuleiro[10][8] :=	soldado;
      tabuleiro[10][9] :=	bomba;
      tabuleiro[10][10] :=	cabo;
   end;
   imprime_tabuleiro(jogador);
end; { corner_blitz }

procedure shoreline_bluff (inicio : no_pecas; jogador : integer);
var
   aux, bandeira, espiao, soldado, cabo, sargento, tenente, capitao, major, coronel, general, marechal, bomba : no_pecas;

begin
   aux := inicio^.prox;
   while (aux <> nil) do
   begin
      aux^.qtde := controle_pecas[aux^.rank];
      aux := aux^.prox;
   end;
   bandeira:= inicio^.prox;
   espiao:= bandeira^.prox;
   soldado:= espiao^.prox;
   cabo:= soldado^.prox;
   sargento:= cabo^.prox;
   tenente:= sargento^.prox;
   capitao:= tenente^.prox;
   major:= capitao^.prox;
   coronel:= major^.prox;
   general:= coronel^.prox;
   marechal:= general^.prox;
   bomba:= marechal^.prox;

   if (jogador=1) then
   begin
      tabuleiro[1][1] :=	soldado;
      tabuleiro[1][2] := 	bomba;
      tabuleiro[1][3] :=	bandeira;
      tabuleiro[1][4] :=	bomba;
      tabuleiro[1][5] :=	general;
      tabuleiro[1][6] :=	soldado;
      tabuleiro[1][7] :=	major;
      tabuleiro[1][8] :=	bomba;
      tabuleiro[1][9] :=	coronel;
      tabuleiro[1][10] :=	soldado;
      tabuleiro[2][1] :=	marechal;
      tabuleiro[2][2] :=	sargento;
      tabuleiro[2][3] :=	coronel;
      tabuleiro[2][4] :=	sargento;
      tabuleiro[2][5] :=	cabo;
      tabuleiro[2][6] :=	capitao;
      tabuleiro[2][7] :=	soldado;
      tabuleiro[2][8] :=	sargento;
      tabuleiro[2][9] :=	cabo;
      tabuleiro[2][10] :=	tenente;
      tabuleiro[3][1] :=	espiao;
      tabuleiro[3][2] :=	major;
      tabuleiro[3][3] :=	tenente;
      tabuleiro[3][4] :=	bomba;
      tabuleiro[3][5] :=	tenente;
      tabuleiro[3][6] :=	cabo;
      tabuleiro[3][7] :=	bomba;
      tabuleiro[3][8] :=	tenente;
      tabuleiro[3][9] :=	major;
      tabuleiro[3][10] :=	capitao;
      tabuleiro[4][1] :=	soldado;
      tabuleiro[4][2] :=	cabo;
      tabuleiro[4][3] :=	sargento;
      tabuleiro[4][4] :=	capitao;
      tabuleiro[4][5] :=	soldado;
      tabuleiro[4][6] :=	soldado;
      tabuleiro[4][7] :=	cabo;
      tabuleiro[4][8] :=	bomba;
      tabuleiro[4][9] :=	capitao;
      tabuleiro[4][10] :=	soldado;
   end
   else
   begin
      tabuleiro[7][1] :=	soldado;
      tabuleiro[7][2] :=	bomba;
      tabuleiro[7][3] :=	bandeira;
      tabuleiro[7][4] :=	bomba;
      tabuleiro[7][5] :=	general;
      tabuleiro[7][6] :=	soldado;
      tabuleiro[7][7] :=	major;
      tabuleiro[7][8] :=	bomba;
      tabuleiro[7][9] :=	coronel;
      tabuleiro[7][10] :=	soldado;
      tabuleiro[8][1] :=	marechal;
      tabuleiro[8][2] :=	sargento;
      tabuleiro[8][3] :=	coronel;
      tabuleiro[8][4] :=	sargento;
      tabuleiro[8][5] :=	cabo;
      tabuleiro[8][6] :=	capitao;
      tabuleiro[8][7] :=	soldado;
      tabuleiro[8][8] :=	sargento;
      tabuleiro[8][9] :=	cabo;
      tabuleiro[8][10] :=	tenente;
      tabuleiro[9][1] :=	espiao;
      tabuleiro[9][2] :=	major;
      tabuleiro[9][3] :=	tenente;
      tabuleiro[9][4] :=	cabo;
      tabuleiro[9][5] :=	tenente;
      tabuleiro[9][6] :=	cabo;
      tabuleiro[9][7] :=	bomba;
      tabuleiro[9][8] :=	tenente;
      tabuleiro[9][9] :=	major;
      tabuleiro[9][10] :=	capitao;
      tabuleiro[10][1] :=	soldado;
      tabuleiro[10][2] :=	cabo;
      tabuleiro[10][3] :=	sargento;
      tabuleiro[10][4] :=	capitao;
      tabuleiro[10][5] :=	soldado;
      tabuleiro[10][6] :=	soldado;
      tabuleiro[10][7] :=	cabo;
      tabuleiro[10][8] :=	bomba;
      tabuleiro[10][9] :=	capitao;
      tabuleiro[10][10] :=	soldado;
   end;
   imprime_tabuleiro(jogador);
end; { shoreline_bluff }

procedure opcoes(opcao, jogador : integer);
var
   inicio : no_pecas;
begin
   if (jogador = 1) then
      inicio := jog1
   else
      inicio := jog2;
   case opcao of
     1 : begin
            imprime_tabuleiro(jogador);
            dispor_pecas(jogador, inicio);
         end;
     2 : blitzkrieg(inicio, jogador);
     3 : tempest_defense(inicio, jogador);
     4 : wheel_danger(inicio, jogador);
     5 : corner_fortress(inicio,jogador);
     6 : corner_blitz(inicio, jogador);
     7 : shoreline_bluff(inicio, jogador);
   else
      writeln('Opção inválida');
   end; { case }
end; { opcoes }

procedure menu(jogador : integer);
begin
   repeat
      writeln('Vez do jogador ', jogador);
      writeln;
      writeln('Escolha a opção:');
      writeln('1: dispor as peças manualmente');
      writeln;
      writeln('Para as opções pré-configuradas digite:');
      writeln('2: Ataque relâmpago');
      writeln('3: Tempestade de defesa');
      writeln('4: Perigo de rodas');
      writeln('5: Fortaleza de canto');
      writeln('6: XXX');
      writeln('7: Blefe litoral');
      readln(opcao);
      opcoes(opcao, jogador);
      writeln('Confirma a opção escolhida? Digite s para sim');
      readln(confirma);
   until (confirma = 's');
end; { menu }

var
   final                                                     : boolean;
   rodada, jogador, linha_atual, linha, coluna_atual, coluna : integer;

{Programa principal}
begin

   clrscr;
   writeln('Seja bem vindo ao COMBATE!':53);
   writeln;
   writeln;
   writeln;
   writeln;
   writeln;
   writeln('Elaborado por Jean, Luísa e Nanci':58);
   writeln;
   writeln;
   writeln;
   writeln;
   writeln;
   writeln('Divirtam-se ^^':47);
   writeln('Digite uma tecla para iniciar o jogo':58);
   readkey;
   clrscr;

   {Preenchimento da área do lago}
   preenche_lago;
   {Aloca memória dos ponteiros dos jogadores}
   new(jog1);
   jog1^.jogador := 1;
   new(jog2);
   jog2^.jogador := 2;
   dados_pecas(jog1, 1);
   dados_pecas(jog2, 2);
   pecas_jogadores;

   {Dispõe peças para os dois jogadores}
   menu(1);
   clrscr;
   menu(2);
   clrscr;

   jogador := 1;
   clrscr;
   rodada := 0;

   {Inicio do jogo}
   repeat
      writeln('Vez do jogador ', jogador);
      writeln;
      imprime_tabuleiro(jogador);
      writeln('Informe as coordenadas da peça que deseja mover');
      readln(linha_atual, coluna_atual);
      {Verifica se o espaço está vazio ou se o a peça escolhida é do jogador}
      if (valida_espaco(jogador, linha_atual,coluna_atual, true)) then
      begin
         repeat
            writeln('Informe as coordenadas do espaço desejado');
            readln(linha, coluna);
         until (move_peca(jogador, linha_atual, coluna_atual, linha, coluna));
         imprime_tabuleiro(jogador);
         delay(3000);
         final := final_jogo(jogador);
         inc(rodada);
         jogador := (rodada mod 2) + 1;
         clrscr;
      end;
   until (final);
   writeln('Fim do jogo');
end.