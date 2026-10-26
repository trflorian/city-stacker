# City Stacker (Unity version)

Mobile arcade game where you build your city by stacking the houses yourself.

> **This branch is archived.** It contains the original Unity version of City Stacker and is no longer developed.
> The game has been ported to [Godot](https://godotengine.org) and active development continues on the
> [`main`](https://github.com/trflorian/city-stacker/tree/main) branch.

Play this version on [itch.io](https://flipflogames.itch.io/city-stacker).

## About this version

- Made with **Unity 2023.2.16f1** using the Universal Render Pipeline, targeting Android
- Main scene: `Assets/Scenes/StackerScene.unity`
- Uses the Input System, TextMesh Pro and DOTween
- `Assets/Scenes/MLStackerScene.unity` contains an [ML-Agents](https://github.com/Unity-Technologies/ml-agents)
  setup that trains an agent to play the game (`Assets/Scripts/ML/GameAgent.cs`, trained model in `Assets/ML-Agents/`)

Binary assets (sprites, audio) are stored with **Git LFS**, run `git lfs pull` after checking out this branch.

## Why Godot?

The game was ported to Godot 4 to get a lighter, fully open source project:

- No Git LFS anymore, all assets are stored directly in git (about 400 KB in total)
- Small, statically typed GDScript codebase with linting in CI
- Gameplay and the original art and sounds are kept, the ML-Agents experiment was not ported

## License

See [LICENSE](LICENSE).
