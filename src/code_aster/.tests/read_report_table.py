import pandas as pd


def main():
    df = pd.read_csv("report.csv")
    # keep only col "ca_version" with value=16.4.8 and col "python_version"=3.11
    df = df[(df["ca_version"] == "16.4.8") & (df["python_version"] == 3.11)]
    # sort the tabla by col "num_failed_tests"
    df = df.sort_values(by=["num_failed_tests"])
    print(df)
    df.to_markdown("report.md")


if __name__ == "__main__":
    main()
