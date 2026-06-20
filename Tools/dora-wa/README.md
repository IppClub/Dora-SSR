# Dora SSR Wa Package

English | [简体中文](README.zh-CN.md)

A language binding project that enables Wa-lang integration with the Dora SSR game engine.

## About

This project bridges two innovative open-source projects:

- **Dora SSR**: A versatile game engine designed for rapid game development across various devices. It features a built-in Web IDE that enables direct game development on mobile phones, open-source handhelds, and other devices.

- **Wa-lang**: A general-purpose programming language specifically designed for WebAssembly. Wa-lang aims to provide a simple, reliable, and statically typed language for high-performance web applications.

This repo provides language bindings and a testing project to demonstrate Wa-lang's capabilities when running on the Dora SSR engine.

## What's in this repo

- Wa-lang bindings for Dora SSR engine APIs
- Testing and Example projects demonstrating Dora-Wa integration and usage

## Installation

- Install Dora SSR engine

    See [Dora SSR Installation Guide](https://dora-ssr.net/docs/tutorial/quick-start)

- Use the Wa compiler integrated in Dora SSR

    Dora SSR ships the Wa compiler used by Dora projects. Use `Dora cli wa ...` commands instead of a separately installed Wa toolchain.

## Usage

1. Step 1: Create a new Dora SSR game project

    - Make sure Dora SSR engine is installed. Wa projects for Dora SSR should be built with the Wa compiler integrated in the engine.

    - Launch Dora SSR software and open the Web IDE in the browser.

    - In the game resource tree on the left side, open the right-click menu of the `Workspace`.

    - Click on the menu item `New` and choose to create a new folder named `Hello`.

2. Step 2: Write Wa game code

    - Start Dora SSR and its Web IDE, then create a new Wa project in command line.

      ```sh
      Dora cli wa init hello_dora --host 192.168.3.1
      cd hello_dora
      ```

    - The command creates `wa.mod`, `src/main.wa`, and `vendor/dora`. To refresh `vendor/dora` later, run `Dora cli wa update` inside the Wa project folder.

    - Write code in `src/main.wa`.

        ```wa
        import "dora"

        func init() {
            // create a sprite
            sprite := dora.NewSpriteWithFile("Image/logo.png")

            // create a root node of the game scene tree
            root := dora.NewNode()

            // mount the sprite to the root node of the game scene tree
            root.AddChild(sprite.Node)

            // receive and process tap event to move the sprite
            root.OnTapBegan(func(touch: dora.Touch) {
                sprite.PerformDef(dora.ActionDefMoveTo(
                    1.0,                  // duration, unit is second
                    sprite.GetPosition(), // start position
                    touch.GetLocation(),  // end position
                    dora.EaseOutBack,     // easing function
                ), false)
            })
        }
        ```

    - To compile only, run the build command. This writes `init.wasm` in the Wa project folder.

      ```sh
      Dora cli wa build --host 192.168.3.1
      ```

    - For the normal command-line workflow, run the project directly. This command builds the WASM file and runs it from the Wa project folder.

      ```sh
      Dora cli wa run --host 192.168.3.1
      ```

      The IP address is the Dora SSR Web IDE address. Replace `Dora` with the path to your Dora executable if it is not on `PATH`. This command uses the Wa compiler integrated in the engine.

3. Step 3: Run the game

    Click the `🎮` icon in the lower right corner of the editor, then click the menu item `Run`. Or press the key combination `Ctrl + r`.

4. Step 4: Publish the game

    - Open the right-click menu of the project folder just created through the game resource tree on the left side of the editor and click the `Download` option.

    - Wait for the browser to pop up a download prompt for the packaged project file.

## Documentation

- [Dora SSR Documentation](https://github.com/ippclub/dora-ssr)
- [Wa-lang Documentation](https://wa-lang.org)

## Development Status

This project is currently in development as both Wa-lang and Dora SSR are evolving. Wa-lang is in its engineering trial stage, and we're actively working on expanding the integration capabilities.

## Contributing

Contributions are welcome! Whether you're interested in:

- Improving language bindings
- Adding new features
- Creating examples
- Fixing bugs
- Improving documentation

Please feel free to submit Pull Requests or open Issues.

## License

MIT

## Contact

- For Dora SSR related questions: [Dora SSR GitHub Issues](https://github.com/ippclub/dora-ssr)
- For Wa-lang related questions: [Wa-lang GitHub Issues](https://github.com/wa-lang/wa)
- For binding specific issues: Create an issue in this repository.
