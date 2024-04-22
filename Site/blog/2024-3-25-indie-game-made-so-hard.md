---
authors: [lijin]
tags: [Dora SSR, Yuescript, Auspice Gear, Game LSD]
---

# From Compiler, Game Engine to Handheld Console: My Journey in Indie Game Development

## Introduction

Developing my own games has been a dream since childhood, particularly fueled by my extensive use of the Warcraft 3 World Editor. This sparked a fascination with game engines and development tools. As a student, I delved into programming and soon felt the urge to expand beyond just using various programming languages for development. I started maintaining a programming language called Yuescript, tailored for writing game logic. My learning journey in graphics led me to rewrite the Cocos2d-x as a learning project, which eventually evolved into the Dora SSR game engine. Later, as my love for handheld gaming consoles grew, I began collaborating on an open, programmable gaming device called the "Auspice Gear", aiming to achieve the ultimate digital freedom in gaming.

## The Fun and Challenges of Game Scripting Languages

<p align="center">
  <img src='/img/3.png' alt='Multilingual Playground!' height='400px'/>
   Multilingual Playground!
</p>

Programming in various languages is exhilarating, as each language offers unique programming philosophies and design principles. For scripting complex and dynamic game mechanics, I prefer using languages that are succinct and expressive. Yuescript, translatable to Lua, fulfills this need beautifully. Over time, as I developed more with my Dora SSR engine, I integrated languages like Teal (which adds static typing to Lua), TypeScript (for enhanced code hints and checks), JSX, and XML (for descriptive, componentized development). Each scripting language shines in specific game development contexts and seamlessly inter-operates through translation to Lua. Beyond Lua-based extensions, the Dora SSR engine also experiments with supporting diverse scripting languages via the WASM virtual machine, such as Rust and upcoming support for C++ and Go, balancing performance with runtime expansibility.

## Innovating with Game Engines

<p align="center">
  <img src='/img/2.png' alt='Game creation at your fingertips!' height='400px'/>
   Game creation at your fingertips!
</p>

While high-performance graphic rendering and complex scene construction are typically associated with game engines, as an indie developer and enthusiast, I believe many 2D games or those blending 2D and 3D effects can also offer highly creative and unique experiences. Ideally, devices for developing and running games should be unrestricted. Thus, Dora SSR was envisioned to provide an accessible and user-friendly environment, or even a full-fledged game development IDE, on as many devices as possible. Game development has become a part of my daily routine, allowing me to enjoy coding and debugging game features leisurely and sporadically, using whatever devices are at hand.

Dora SSR features a built-in Web IDE server within the game engine runtime, enabling code writing, running, and debugging directly on any terminal device via a web browser. This integration provides visual hints and access to various game development and resource management tools. Presently, Dora SSR supports game development on platforms like Windows, macOS, iOS, Android, and several Linux distributions.

## Pursuing the Dream of a Free and Open Gaming Handheld

<p align="center">
  <img src='/img/1.png' alt='Open source everything?' height='400px'/>
   Open source everything? Want it for both software and hardware!
</p>

Despite the progress, the pursuit of an unrestricted and open gaming development experience is far from over. As a veteran handheld gaming enthusiast dissatisfied with many commercial open-source handhelds, I envisioned a device not just for playing games but also for freely developing, running, and even distributing homemade games. Many manufacturers restrict programmability for profit, so with like-minded hardware enthusiasts, we developed the fully open "Auspice Gear", offering modular customization of its core components and design.

<p align="center">
  <img src='/img/auspice-gear.png' alt='Auspice Gear + Dora SSR'/>
  Auspice Gear + Dora SSR
</p>

## Returning to the Essence of Game Creation

<p align="center">
  <img src='/img/lsd-banner.jpg' alt='An open-source indie game project'/>
   An open-source indie game project made by the community called 'Luv Sense Digital'
</p>

So, did I eventually make my game? Yes, though it's not entirely complete yet. Before the generative AI boom of 2020, we envisioned a future where AI played a central role in games—where humans, having their material needs fully met, engage in games to provide creative and intelligent data for AI training. This data, assessed by futuristic banks, determines an individual's monetary worth. The AI trained with this data helps with all aspects of material production, individual nurturing, and social management. This narrative reflects our ongoing quest to define ourselves through our creations rather than being defined by circumstances into which we were born.

If you're interested in our work on programming languages, game engines, gaming handhelds, or our game project, feel free to star our repositories or join our discussion groups. Although our projects are still in their early stages, they are continuously integrated and iterated upon, offering a glimpse into our progress and processes.

We warmly invite everyone passionate about game development to join us. Whether contributing code, providing feedback, or sharing our projects, your efforts help us collectively realize the dream of freely developing games.

## Project Links

- Game Engine: [Dora-SSR on GitHub](https://github.com/IppClub/Dora-SSR)
- Yuescript Language: [Yuescript on GitHub](https://github.com/pigpigyyy/Yuescript)
- "Luv Sense Digital" Open Source Game Project: [Documentation](https://luv-sense-digital.readthedocs.io)