# Dora SSR Wa Package

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

- Install Wa-lang compiler

    See [Wa-lang Installation Guide](https://wa-lang.github.io/man/en/1.InstallAndGetStart/1.2.Install.html)

## Usage

1. Step 1: Create a new Dora SSR game project

    - Make sure Dora SSR engine and Wa-lang compiler are installed.

    - Launch Dora SSR software and open the Web IDE in the browser.

    - In the game resource tree on the left side of the Dora Web IDE, open the right-click menu of the game resource tree.

    - Click on the menu item `New` and choose to create a new folder named `Hello`.

2. Step 2: Write Wa game code

    - Create a new Wa project in command line.

      ```sh
      wa init -n hello_dora --wasi
      cd hello_dora
      ```

    - Copy the whole module from `this-repo/vendor/dora` to `hello_dora/vendor/dora`.

    - Write code in `src/main.wa`.

        ```wa
        import "dora"

        func main() {
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

    - Build it into WASM file.

      ```sh
      wa build -optimize
      ```

    - Upload it to engine to run. From Dora SSR Web IDE, Open the right-click menu of the game resource tree on the created folder `Hello`. Click on the menu item `Upload` and choose the compiled WASM file named `init.wasm` to upload.

    - Or use a helper script [upload.py](https://github.com/IppClub/Dora-SSR/blob/main/Tools/dora-rust/dora-test/upload.py) with commad `python3 upload.py 192.168.3.1 Hello` inside your Wa project folder to upload WASM file. The IP address is the Dora SSR Web IDE address.

3. Step 3: Run the game

    Click the `🎮` icon in the lower right corner of the editor, then click the menu item `Run`. Or press the key combination `Ctrl + r`.

4. Step 4: Publish the game

    - Open the right-click menu of the project folder just created through the game resource tree on the left side of the editor and click the `Download` option.

    - Wait for the browser to pop up a download prompt for the packaged project file.

## Documentation

- [Dora SSR Documentation](https://github.com/ippclub/dora-ssr)
- [Wa-lang Documentation](https://wa-lang.org)
- [Integration Guide](link-to-your-docs)

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
- For binding specific issues: [Create an issue in this repository]
