from jinja2 import Environment, FileSystemLoader, select_autoescape

# Set up Jinja2 environment
env = Environment(
    loader=FileSystemLoader(searchpath="./templates"),
    autoescape=select_autoescape(['html', 'xml'])
)

# List of your HTML pages (excluding base.html)
pages = ["table1.html", "table2.html", "dashboard.html"]

for page in pages:
    # Load template
    template = env.get_template(page)

    # Render template
    output = template.render()

    # Write output to file
    with open(page, "w") as file:
        file.write(output)
