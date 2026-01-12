<a id="readme-top"></a>

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![project_license][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<br />
<div align="center">
  <h3 align="center">Asterisk WebUI</h3>

  <p align="center">
    A basic web interface for the Asterisk phone system.
    <br />
    <a href="https://github.com/xanderboy2001/asterisk-webui"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/xanderboy2001/asterisk-webui/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/xanderboy2001/asterisk-webui/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
    &middot;
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## About the Project
This is a basic web interface for the Asterisk phone systems.
It is a collection of Bash scripts that can be run via buttons.
It dynamically generates input fields to collect the arguments for the scripts.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built with

* [![PHP][PHP.js]][PHP-url]
* [![HTML][HTML.js]][HTML-url]
* [![JavaScript][JavaScript-js]][JavaScript-url]
* [![Bash][Bash-js]][Bash-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



## Getting Started
We are going to assume you already have an Asterisk phone system set up and configured.
These instructions will only walk through installing the tools required for running the web interface.

### Prerequisites
This guide assumes you are using an Ubuntu (or other Debian-based) distrubution.
If you are using Windows, follow the instructions below.

<details>
  <summary><strong>Installing Ubuntu via WSL</strong></summary>
  
  1. Right click the Start button and select **Windows PowerShell (Admin)**. On Windows 11, this may be called **Terminal (Admin)**.
  2. Run the following command:

```PowerShell
wsl --install Ubuntu
```

  3. Restart your computer.
  4. Launch Ubuntu from the Start Menu
</details>

**On your Ubuntu machine (or WSL), you will need to install the following:**
* PHP
  ```sh
  sudo apt update && sudo apt install php
  ```

### Installation

  1. Clone the repo
     ```sh
     git clone https://github.com/xanderboy2001/asterisk-webui.git
     ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage
Follow these instructions to run the site locally:
  1. Run a PHP test server
     ```sh
     php -S localhost:8000
     ```
  2. Open your browser to http://localhost:8000

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Roadmap

- [ ] Rework shell scripts to properly accept input from site
    - [ ] Develop helper script to sanitize and validate inputs
- [ ] Add coloring with CSS
- [ ] Add dark mode

See the [open issues](https://github.com/xanderboy2001/asterisk-webui/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Contributing

Any contributions to this project are **greatly appreciated**.

If you have any suggestions, please fork the repo and make a pull request. You can also just open an issue with the tag "enhancement".

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some amazing feature!'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>


### Top contributors:

<a href="https://github.com/xanderboy2001/asterisk-webui/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=xanderboy2001/asterisk-webui" alt="contrib.rocks image" />
</a>


## License

Distributed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for more information

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/xanderboy2001/asterisk-webui.svg?style=for-the-badge
[contributors-url]: https://github.com/xanderboy2001/asterisk-webui/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/xanderboy2001/asterisk-webui.svg?style=for-the-badge
[forks-url]: https://github.com/xanderboy2001/asterisk-webui/network/members
[stars-shield]: https://img.shields.io/github/stars/xanderboy2001/asterisk-webui.svg?style=for-the-badge
[stars-url]: https://github.com/xanderboy2001/asterisk-webui/stargazers
[issues-shield]: https://img.shields.io/github/issues/xanderboy2001/asterisk-webui.svg?style=for-the-badge
[issues-url]: https://github.com/xanderboy2001/asterisk-webui/issues
[license-shield]: https://img.shields.io/github/license/xanderboy2001/asterisk-webui.svg?style=for-the-badge
[license-url]: https://github.com/xanderboy2001/asterisk-webui/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/alexander-e-christian
<!-- Shields.io badges -->
[PHP.js]: https://img.shields.io/badge/php-%23777BB4.svg?&logo=php&logoColor=white
[PHP-url]: https://www.php.net
[HTML.js]: https://img.shields.io/badge/HTML-%23E34F26.svg?logo=html5&logoColor=white
[HTML-url]: https://en.wikipedia.org/wiki/HTML
[JavaScript-js]: https://img.shields.io/badge/JavaScript-F7DF1E?logo=javascript&logoColor=000
[JavaScript-url]: https://en.wikipedia.org/wiki/JavaScript
[Bash-js]: https://img.shields.io/badge/Bash-4EAA25?logo=gnubash&logoColor=fff
[Bash-url]: https://en.wikipedia.org/wiki/Bash_(Unix_shell)
