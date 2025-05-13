import Image from "next/image";
import Link from "next/link";

export default function Home() {
  return (
    <div className="flex flex-col min-h-screen">
      {/* Header */}
      <header className="flex justify-between items-center w-full bg-white shadow-sm p-4">
        <div className="flex items-center gap-4">
          <Image
            src="/philly-logo.png"
            alt="Philadelphia Logo"
            width={60}
            height={60}
            priority
          />
          <h1 className="text-xl font-bold">Philadelphia Council Districts and Health</h1>
        </div>

        <nav>
          <ul className="flex gap-6">
            <li>
              <Link href="#intro" className="hover:text-blue-600 transition-colors">
                Home
              </Link>
            </li>
            <li>
              <Link href="#dashboard" className="hover:text-blue-600 transition-colors">
                Dashboard
              </Link>
            </li>
            <li>
              <Link href="#about" className="hover:text-blue-600 transition-colors">
                About
              </Link>
            </li>
          </ul>
        </nav>
      </header>

      <main className="flex-1 container mx-auto p-6">
        {/* Introduction Section */}
        <section id="intro" className="mb-12">
          <h2 className="text-2xl font-bold mb-4">Philadelphia Council Districts Health Dashboard</h2>
          <p className="mb-4">
            Welcome to the Philadelphia Council Districts Health Dashboard. This dashboard provides information
            about health metrics across different council districts in Philadelphia.
          </p>
          <p>
            Scroll down to explore the dashboard or use the navigation above to jump to specific sections.
          </p>
        </section>

        {/* Dashboard Section */}
        <section id="dashboard" className="mb-12">
          <h2 className="text-2xl font-bold mb-6">Interactive Dashboard</h2>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Map Panel */}
            <div className="md:col-span-2 bg-gray-100 rounded-lg p-4 min-h-[400px] shadow-md">
              <h3 className="text-xl mb-4">Philadelphia Council Districts Map</h3>
              <div className="bg-gray-200 h-[350px] flex items-center justify-center">
                {/* Map will be implemented here */}
                <p className="text-gray-500">Interactive map will be displayed here</p>
              </div>
            </div>

            {/* Controls Panel */}
            <div className="bg-gray-100 rounded-lg p-4 shadow-md">
              <h3 className="text-xl mb-4">Dashboard Controls</h3>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Select Health Metric</label>
                  <select className="w-full p-2 border rounded">
                    <option>Life Expectancy</option>
                    <option>Obesity Rate</option>
                    <option>Smoking Rate</option>
                    <option>Access to Healthcare</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1">Select Year</label>
                  <select className="w-full p-2 border rounded">
                    <option>2023</option>
                    <option>2022</option>
                    <option>2021</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1">Filter by District</label>
                  <select className="w-full p-2 border rounded">
                    <option>All Districts</option>
                    <option>District 1</option>
                    <option>District 2</option>
                    <option>District 3</option>
                    {/* Add all districts */}
                  </select>
                </div>
              </div>
            </div>

            {/* Data Visualization Panel */}
            <div className="md:col-span-3 bg-gray-100 rounded-lg p-4 shadow-md">
              <h3 className="text-xl mb-4">Health Metrics Analysis</h3>
              <div className="bg-gray-200 h-[300px] flex items-center justify-center">
                {/* Charts will be implemented here */}
                <p className="text-gray-500">Charts and data visualizations will be displayed here</p>
              </div>
            </div>
          </div>
        </section>

        {/* About & Acknowledgements */}
        <section id="about" className="mb-12">
          <h2 className="text-2xl font-bold mb-4">About This Project</h2>
          <p className="mb-4">
            This dashboard aims to visualize health disparities across Philadelphia's council districts
            to inform policy decisions and community health initiatives.
          </p>

          <h3 className="text-xl font-bold mt-6 mb-3">Acknowledgements</h3>
          <p className="mb-4">
            Data for this dashboard is sourced from the Philadelphia Department of Public Health,
            the U.S. Census Bureau, and other public health organizations.
          </p>
          <p>
            Special thanks to all contributors and organizations who made this project possible.
          </p>
        </section>
      </main>

      <footer className="bg-gray-800 text-white p-6">
        <div className="container mx-auto">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div>
              <h3 className="text-lg font-bold mb-3">Philadelphia Council Districts and Health</h3>
              <p className="text-sm text-gray-300">
                A data visualization project focused on health metrics across Philadelphia.
              </p>
            </div>

            <div>
              <h3 className="text-lg font-bold mb-3">Resources</h3>
              <ul className="space-y-2 text-sm text-gray-300">
                <li><a href="#" className="hover:text-white">Data Sources</a></li>
                <li><a href="#" className="hover:text-white">Methodology</a></li>
                <li><a href="#" className="hover:text-white">Contact Us</a></li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-bold mb-3">Connect</h3>
              <div className="flex space-x-4">
                <a href="#" aria-label="GitHub">
                  <svg className="w-6 h-6 text-gray-300 hover:text-white" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                    <path fillRule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" clipRule="evenodd" />
                  </svg>
                </a>
              </div>
            </div>
          </div>

          <div className="mt-8 pt-6 border-t border-gray-700 text-sm text-center text-gray-400">
            &copy; {new Date().getFullYear()} Philadelphia Council Districts Health Dashboard
          </div>
        </div>
      </footer>
    </div>
  );
}
