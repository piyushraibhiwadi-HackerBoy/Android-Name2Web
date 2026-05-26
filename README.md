# Company Email Scraper - Flutter App

A Flutter mobile application for Android and iOS that scrapes company websites and emails from DuckDuckGo search results. This app is a mobile version of the Python-based desktop scraper, optimized for email marketing purposes.

## Features

- **Company Search**: Search for company websites using DuckDuckGo HTML search engine
- **Multiple Email Extraction**: Extracts multiple emails per company (improved from single email in original)
- **Website Discovery**: Finds up to 3 websites per company
- **Social Media Detection**: Extracts Facebook and LinkedIn profiles
- **Domain Blacklist**: Block unwanted domains from being scraped
- **Real-time Progress**: Live progress tracking and logging
- **Data Persistence**: SQLite database for storing results
- **CSV Export**: Export results to CSV format for email marketing campaigns
- **Mobile-First UI**: Material Design interface optimized for mobile devices

## Key Improvements Over Python Version

1. **Multiple Emails per Company**: Now extracts all available emails from each company website, not just one
2. **Mobile Platform**: Runs on Android and iOS devices
3. **No Chrome Dependency**: Uses HTTP requests instead of Selenium/Chrome WebDriver
4. **Modern UI**: Material Design interface with dark theme support
5. **Touch-Optimized**: Designed for mobile interaction patterns

## Installation

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio / Xcode (for platform-specific builds)
- Valid Android/iOS development environment

### Setup

1. Navigate to the project directory:
```bash
cd company_email_scraper
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
company_email_scraper/
├── lib/
│   ├── models/
│   │   ├── company_result.dart       # Data model for scraped results
│   │   ├── blacklist_item.dart       # Data model for blacklist entries
│   │   └── scraping_progress.dart    # Progress tracking model
│   ├── services/
│   │   ├── scraper_service.dart      # DuckDuckGo search & email extraction
│   │   ├── database_service.dart     # SQLite database operations
│   │   ├── blacklist_service.dart    # Blacklist management
│   │   └── export_service.dart       # CSV/JSON export functionality
│   ├── screens/
│   │   ├── home_screen.dart          # Main input and control screen
│   │   ├── results_screen.dart       # Results display and export
│   │   └── blacklist_screen.dart     # Blacklist management
│   ├── widgets/
│   └── main.dart                     # App entry point
├── android/                          # Android configuration
├── ios/                              # iOS configuration
└── pubspec.yaml                      # Dependencies
```

## Usage

### 1. Add Company Names

- Open the app and navigate to the Home screen
- Paste or type company names (one per line) in the input field
- Example:
  ```
  Apple Inc
  Microsoft Corporation
  Google LLC
  ```

### 2. Configure Settings

- **Extract Emails**: Toggle to enable/disable email extraction
- **Delay (seconds)**: Set delay between requests (recommended: 2-3 seconds)

### 3. Start Scraping

- Tap the **START** button to begin scraping
- Monitor progress in real-time via the progress bar and live log
- Use **PAUSE** to temporarily pause scraping
- Use **STOP** to completely stop the process

### 4. View Results

- Tap the **list icon** in the app bar to view all results
- Search/filter results by company name
- Expand each result to view:
  - Websites (up to 3)
  - Emails (multiple per company)
  - Social media profiles (Facebook, LinkedIn)
  - Scraping timestamp

### 5. Export Data

- On the Results screen, tap the **download icon**
- Choose CSV format for email marketing tools
- Share the file via email, cloud storage, or other apps

### 6. Manage Blacklist

- Tap the **block icon** in the app bar
- Add domains to block (e.g., `example.com`)
- Remove domains from blacklist
- Reset to default blacklist
- Clear all blacklist entries

## Technical Details

### Scraping Process

1. **Search Query**: Constructs DuckDuckGo HTML search query for each company
2. **HTML Parsing**: Parses search results to extract:
   - Website URLs (up to 3, excluding blacklisted domains)
   - Facebook profiles
   - LinkedIn profiles
   - Email addresses from snippets
3. **Website Visit**: Visits the first website to extract additional emails
4. **Email Extraction**: Uses regex patterns to find valid email addresses
5. **Data Storage**: Saves results to SQLite database

### Email Extraction Algorithm

- Extracts emails from search result snippets
- Visits company websites to find additional emails
- Checks `mailto:` links in HTML
- Filters out invalid/test emails
- Returns all unique emails found per company

### Blacklist System

- Default blacklist includes common non-company domains:
  - Social media platforms (Facebook, LinkedIn, Twitter, etc.)
  - Business directories (Yelp, Yellow Pages, etc.)
  - Government sites (SEC, Companies House, etc.)
  - Search engines (Google, Bing, DuckDuckGo, etc.)
- Custom domains can be added/removed by user

## Dependencies

- `http`: HTTP requests for web scraping
- `html`: HTML parsing
- `sqflite`: SQLite database for local storage
- `path_provider`: File system access
- `share_plus`: File sharing and export
- `provider`: State management
- `csv`: CSV export functionality
- `url_launcher`: Link opening

## Permissions

### Android
- `INTERNET`: Required for web scraping
- `ACCESS_NETWORK_STATE`: Check network connectivity

### iOS
- Network access is automatically configured

## Limitations

- **No JavaScript Execution**: Unlike the Python version with Selenium, this app uses HTTP requests only
- **Rate Limiting**: DuckDuckGo may rate-limit requests; use appropriate delays
- **Mobile Network**: Performance depends on mobile network quality
- **Battery Usage**: Scraping many companies may drain battery

## Troubleshooting

### Scraping Fails

- Check internet connection
- Increase delay between requests
- Verify DuckDuckGo is accessible
- Check blacklist settings

### No Emails Found

- Some companies may not have public emails
- Emails may be hidden behind JavaScript
- Try visiting the website manually to verify

### Export Issues

- Ensure sufficient storage space
- Check file permissions
- Try exporting smaller batches

## Future Enhancements

- [ ] Support for other search engines
- [ ] Proxy support for privacy
- [ ] Cloud sync for results
- [ ] Advanced email validation
- [ ] Batch processing with queue management
- [ ] Custom email extraction patterns
- [ ] Integration with email marketing platforms

## License

This project is a conversion of the original Python-based company scraper for mobile platforms.

## Support

For issues or questions, please refer to the original Python application documentation or contact the development team.
