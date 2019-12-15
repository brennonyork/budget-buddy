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

## Output File

The output file consists of 4 columns:

1. *Transaction Post Date* - This is the date the transaction was posted to
the account. This *is not* the date the transaction happened. Unfortunately
not all financial sources provide the date the transaction happened as well
as the posted date, so we only use posted date.
2. *Merchant String* - This is the string that comes through for describing
the merchant of the transaction. Some financial institutions might attempt to
clean this string, other won't and can look quite confusing.
3. *Category* - This is the financial (or user) supplied category for the
given transaction. If the user supplies a ruleset file then this category
could be provided from a match in that file. Alternatively this could be
blank if a given financial institution doesn't provide categorization (some
don't).
4. *Price* - The price of this transaction. Prices are negative if they're
debits and positive if they're credits to the account.

## Financial Sources Supported

Currently, with hacky bash scripting, budget-buddy can reasonably detect and
supports files from:

* Chase
* USAA
* Capital One
* Bank of America

# Categorization

One of the powerful utilities budget-buddy has is the ability to apply a
series of regexes to the merchant string (eg "LYFT   *RIDE TUE 6AM") and, if
it finds a match, changes the category label for that transaction.

This feature was the original purpose for building budget-buddy as it allows
individuals the power to create categories meaningful to them based on
intuitive rule logic (regexes) and apply them to all their transactions.
This creates a foundation for further tooling, etc to be used / built
to provide details about how individuals spend their money.

## Ruleset File Layout

The ruleset file is in csv format with 2 columns. The first is the category
to apply *iff* the regex matches. The second column is the Python-based regex
to apply against the merchant string to check for a match. Comments can be
placed in the file with the `#` character.

The core of the matching comes from the Python `re.search()` function. If a
merchant string matches multiple regexes then the longest match will apply.

For example:
```
 $ cat rules.csv
 > Food & Drink, ^SQ \*
 > Coffee, ^SQ \*FIFTY/FIFTY$
```

We are first stating that all transactions through Square
(eg the "SQ *<some restaurant>" pattern) should be matched and apply the
"Food & Drink" category. However, if we find a transaction such as
"SQ *FIFTY/FIFTY" explicitly then we should apply the label "Coffee".
"Coffee" would be the correct label applied because the "SQ \*" would only
match up to a length of 4 while the latter would match 15 characters, thus
applying the longer match.

In a worst case where multiple matches are of equal length it would apply
the first rule in the file.

More details and examples can be found in the comments of the
`rules.example` file.

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