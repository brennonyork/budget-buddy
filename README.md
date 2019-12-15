# budget-buddy

An alternate financial tracking platform made for command-line competent
individuals to easily merge financial statements from various providers.

* *sort, merge, and unify* your financial statements
* apply rules to *simplify categorization* of individual transactions
* split transaction history for easy *month-over-month spend comparisons*
* *no logins, no personal info needed* - your data stays with you

# Usage

budget-buddy first requires one to first log into their various financial
providers and download transaction statements in csv form.

Once files are downloaded (typically in a "Downloads" folder) all one needs
to do is tell budget-buddy where that directory is to scan for files. For
example:

` $ budget-buddy -d ~/Downloads/`

budget-buddy creates an output file inside the `output/` directory, lovingly
called `output.csv`, which will then contain a merged, sorted, list of all
one's financial transactions.

# Categorization

One of the powerful utilities budget-buddy has is the ability to apply a
series of regexes to the merchant string (eg "LYFT   *RIDE TUE 6AM") and, if
it finds a match, changes the category label for that transaction.

This feature was the original purpose for building budget-buddy as it allows
individuals the power to create categories meaningful to them based on
intuitive rule logic (regexes) and apply them to all their transactions.
This creates a foundation for further tooling, etc to be used / built
to provide details about how individuals spend their money.

# Why create this?

The first step to financial freedom is knowing where your money goes. As I
was exploring where my money was going through various tools (personal
capital, mint, google sheets) I wasn't getting the simplicity and clarity I
was looking for. So, as any person with not enough time on their hands does,
they pick up yet another project thinking they'll have time to finish it.
This want started a solo hackathon over a thanksgiving and budget-buddy was
born.

At worst, budget-buddy is a text-based replacement for Mint if someone chose
to go as far as creating 1-for-1 mappings of merchant strings to categories.
If nothing else I'd rather have a text-based version of Mint than what they
provide. Worse though, Mint explicitly won't backfill data from your
financial institutions past 90 days making it hard to understand spend over
time unless you've been on their platform (sorry new users).

So now budget-buddy is here. It can easily look back as far as you care to
download financial statements that your provider allows. Every time it runs
it runs through your entire financial history (because honestly it isn't
that big) allowing you to backfill transactions, change category labels, or
add new financial sources.

*budget-buddy doesn't require your personal info,
it doesn't require a login, and it won't ever contact you about trying to
take a fee to help you manage your finances better. And, best of
all, its free.*