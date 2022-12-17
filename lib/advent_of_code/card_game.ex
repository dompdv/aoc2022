defmodule AdventOfCode.CardGame do
  # Constantes
  # liste des couleurs (les :xxx sont des atomes. (sous le capot, ce sont des entiers garantis uniques))
  @colors [:pique, :coeur, :carreau, :trefle]
  # liste des series
  @series [2, 3, 4, 5, 6, 7, 8, 9, 10, :valet, :dame, :roi, :as]

  # Calculé à la compilation. C'est la syntaxe de liste en compréhension. Chaque carte est un couple {couleur, valeur}
  @cartes for c <- @colors, s <- @series, do: {c, s}

  # Comparaison de deux cartes ayant la même couleur (le pattern matching permet de le tester)
  # Je compare simplement les index dans les constantes
  # La fonction find_index demande une fonction comme deuxième paramètre. J'utilise une notation raccourcie de
  # fonction lambda. &(&1==ca1) pourrait s'écrire en Python "lambda x: x==co1"
  def cmp({co, ca1}, {co, ca2}),
    do: Enum.find_index(@series, &(&1 == ca1)) > Enum.find_index(@series, &(&1 == ca2))

  # comparaison de deux cartes de couleurs différentes: on compare seulement les couleurs
  def cmp({co1, _}, {co2, _}),
    do: Enum.find_index(@colors, &(&1 == co1)) > Enum.find_index(@colors, &(&1 == co2))

  # Le jeu lui-même
  # Le pattern matching permet de tester si on arrive au round 26 (dans ce cas, on renvoie les deux scores)
  def round(_, _, score1, score2, 26), do: {score1, score2}

  # card1 et card2 sont les deux premières cartes des tas des joueurs
  def round([card1 | r1], [card2 | r2], score1, score2, rounds) do
    if cmp(card1, card2) do
      # appel récursif à "round()", avec le bon score et le compteur incrémentés
      round(r1, r2, score1 + 1, score2, rounds + 1)
    else
      round(r1, r2, score1, score2 + 1, rounds + 1)
    end
  end

  # fonction principale
  def play() do
    # On mélange
    melange = Enum.shuffle(@cartes)
    # on coupe le jeu en deux parties égales
    {cartes1, cartes2} = Enum.split(melange, div(Enum.count(melange), 2))
    # on joue
    round(cartes1, cartes2, 0, 0, 0)
  end
end
