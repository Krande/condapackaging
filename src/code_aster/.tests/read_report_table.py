import pandas as pd


def main():
    # Make sure that the column python_version does not write 3.10 as 3.1
    df = pd.read_csv("report.csv", dtype={"python_version": str})
    # keep only col "ca_version" with value=16.4.8 and col "python_version"=3.11
    # df = df[(df["ca_version"] == "16.4.8") & (df["python_version"] == 3.11)]
    # sort the tabla by col "num_failed_tests"
    df = df.sort_values(by=["num_failed_tests", "date"], ascending=[True, False])
    print(df)
    df.to_markdown("report.md")


if __name__ == "__main__":
    main()
