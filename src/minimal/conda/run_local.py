import re

import markdown


# This needs the following packages
# mamba install markdown pandas lxml html5lib BeautifulSoup4

def get_long_description():
    """Get the long description from the README file."""
    with open("README.md") as f:
        md_str = f.read()
    html = markdown.markdown(md_str)

    # Convert Markdown tables to HTML tables
    html = re.sub(r'\|([^\|]*)\|([^\|]*)\|',
                  r'<table class="table"><thead><tr><th>\1</th><th>\2</th></tr></thead><tbody>', html)
    html = re.sub(r'\|([^\|]*)\|', r'<tr><td>\1</td>', html)
    html = re.sub(r'(\n)</tr>', r'</tr>', html)
    html = re.sub(r'</tbody>\n</table>', r'</td></tr></tbody></table>', html)

    with open('test.html', 'w') as f:
        f.write(html)

    return html


def main():
    res = get_long_description()
    print(res)


if __name__ == '__main__':
    main()
