
# booly_marketvan

`booly_marketvan` is a FiveM script that spawns a van at random locations with a ped inside who sells items to the player. The script is designed to create dynamic, immersive interactions within your FiveM server.

## Features

- **Random Van Spawning**: The van (`speedo4` model) spawns at various preset locations.
- **Interactive Ped**: A ped is seated in the back of the van, ready to sell items to players.
- **Automatic Door Opening**: The van's doors open automatically when players approach, using PolyZones.
- **Debug Mode**: Conditional debug prints can be enabled or disabled via configuration.
- **Spotlight Mode**: Conditional spotlight to highlight the weapon previews can be enabled or disabled via configuration.

## Requirements

- **[ox_lib](https://github.com/overextended/ox_lib)**: A library for various helper functions and utilities.
- **Mythic Framework**: A framework providing essential components for role-playing scenarios in FiveM.

## Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/DrBooly-491/booly_marketvan.git
   ```

2. **Install Dependencies:**
   Make sure you have the following dependencies installed on your server:
   - `ox_lib`
   - `Mythic Framework`

3. **Add to Server Resources:**
   Add `booly_marketvan` to your server resources in the `server.cfg`:
   ```cfg
   ensure booly_marketvan
   ```

4. **Configure the Script:**
   Edit the `config.lua` file to adjust settings such as PolyZone locations, debug mode, etc.

## Configuration

The `config.lua` file allows you to customize various aspects of the script, including:

- **Van Spawn Locations**: Define preset locations where the van can spawn.
- **Debug Mode**: Enable or disable debug prints using `Config.Debug`.
- **PolyZone Settings**: Adjust the size and position of PolyZones that trigger door opening.

## Usage

Once installed and configured, the script will handle spawning the van and managing player interactions automatically. Players approaching the van will find the doors opening, with the ped ready to conduct business.

## Contributing

Feel free to fork this repository and submit pull requests. Contributions are always welcome!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
