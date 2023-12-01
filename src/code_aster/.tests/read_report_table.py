import pandas as pd

BASE_TMPL = """<!-- table1.html -->
{% extends "base.html" %}

{% block title %}Table 1{% endblock %}

{% block content %}
{html_content}
<h1>Table 1</h1>
{% endblock %}
"""


def make_interactive_report(df: pd.DataFrame):
    # Convert DataFrame to HTML
    html_table = df.to_html(classes='table table-striped', index=False, border=0)

    # HTML and JavaScript for interactivity with filtering, adjusted to prevent sorting on filter input click
    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Interactive Table with Filtering</title>
        <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.css">
        <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/colreorder/1.5.2/css/colReorder.dataTables.min.css">
        <script type="text/javascript" charset="utf8" src="https://code.jquery.com/jquery-3.5.1.js"></script>
        <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.js"></script>
        <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/colreorder/1.5.2/js/dataTables.colReorder.min.js"></script>
    </head>
    <body>
        <table id="data_table" class="table table-striped">
            <thead>
                {df.columns.to_series().apply(lambda x: f"<th>{x}</th>").str.cat()}
            </thead>
            <tfoot>
                {df.columns.to_series().apply(lambda x: f"<th>{x}</th>").str.cat()}
            </tfoot>
            <tbody>
                {html_table.split('<tbody>')[1]}
            </tbody>
        </table>
        <script>
        $(document).ready( function () {{
            // Initialize DataTable with ColReorderWithResize
            var table = $('#data_table').DataTable({{
                colReorder: true
            }});

            // Add input elements for filtering to each column's footer
            $('#data_table tfoot th').each( function () {{
                var title = $(this).text();
                $(this).html( '<input type="text" placeholder="Search '+title+'" />' );
            }});

            // Apply the filter
            table.columns().every( function () {{
                var that = this;

                $('input', this.footer()).on('keyup change', function () {{
                    if (that.search() !== this.value) {{
                        that.search(this.value).draw();
                    }}
                }});
            }});

            // Stop sorting when clicking on input fields
            $('#data_table tfoot input').on('click', function(e) {{
                e.stopPropagation();
            }});
        }} );
        </script>
    </body>
    </html>
    """

    # Write to an HTML file
    with open("web/data_tables/test_results.html", "w") as file:
        file.write(html)


def main():
    # Make sure that the column python_version does not write 3.10 as 3.1
    df = pd.read_csv("report.csv", dtype={"python_version": str})
    # keep only col "ca_version" with value=16.4.8 and col "python_version"=3.11
    # df = df[(df["ca_version"] == "16.4.8") & (df["python_version"] == 3.11)]
    # sort the tabla by col "num_failed_tests"
    df = df.sort_values(by=["num_failed_tests", "date"], ascending=[True, False])
    print(df)
    df.to_markdown("report.md")
    make_interactive_report(df)


if __name__ == "__main__":
    main()
