defmodule AdventOfCode.CardGameN do
  import Enum

  # Constantes
  @colors [:pique, :coeur, :carreau, :trefle]
  @series [2, 3, 4, 5, 6, 7, 8, 9, 10, :valet, :dame, :roi, :as]
  @cartes for c <- @colors, s <- @series, do: {c, s}
  @n_cartes count(@cartes)

  # Je défini une numérotation sur les valeurs de carte
  def valeur_carte(nil), do: 0

  def valeur_carte({co, ca}),
    do: find_index(@colors, &(&1 == co)) * count(@series) + find_index(@series, &(&1 == ca))

  # Le jeu lui-même
  # cartes : dictionnaire %{numéro du joueur => [liste des cartes]}
  # scores : dictionnaire %{numéro du joueur => score}
  def round(cartes, scores) do
    jeu =
      for {j, cartes_joueur} <- cartes do
        # je dois gérer le cas où un joueur n'a plus de cartes (devrait pas arriver, mais bon)
        case cartes_joueur do
          [] -> {j, nil, []}
          # je crée un triplet avec {numéro du joueur, carte posée sur la table, reste des cartes dans les mains du joueur}
          [c | r] -> {j, c, r}
        end
      end

    # Je trouve le vainqueur
    {vainqueur, _, _} = max_by(jeu, fn {_, c, _} -> valeur_carte(c) end)

    # Les nouvelles cartes dans les mains des joueurs. La syntaxe into: %{} permet de créer une compréhension de dictionnaire
    new_cartes = for {j, _, r} <- jeu, into: %{}, do: {j, r}

    # Mise à jour du score. La fonction update! applique une fonction de modification à un élément de dictionnaire
    new_scores = Map.update!(scores, vainqueur, &(&1 + 1))

    # On arrête le jeu si un joueur n'a plus de cartes
    un_joueur_a_plus_de_carte = any?(for v <- Map.values(new_cartes), do: v == [])

    if un_joueur_a_plus_de_carte,
      do: new_scores,
      else: round(new_cartes, new_scores)
  end

  # fonction principale
  def play(n_joueurs) do
    # On mélange
    melange = shuffle(@cartes)
    # Distribution: je distibue les cartes une par une à chaque joueur
    cartes =
      reduce(with_index(melange), %{}, fn {c, i}, acc ->
        joueur = rem(i, n_joueurs)
        en_main = Map.get(acc, joueur, [])
        Map.put(acc, joueur, [c | en_main])
      end)

    # scores à 0
    scores = for i <- 0..(n_joueurs - 1), into: %{}, do: {i, 0}
    # C'est parti
    round(cartes, scores)
  end
end
