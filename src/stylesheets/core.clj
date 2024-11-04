(ns stylesheets.core
  (:require [babashka.fs :as fs]
            [babashka.process :refer [shell]]
            [clojure.string :as str]
            [ring.adapter.jetty :refer [run-jetty]]
            [ring.middleware.params :refer [wrap-params]]
            [ring.middleware.multipart-params :refer [wrap-multipart-params]]
            [ring.middleware.multipart-params.temp-file :as tf])
  (:gen-class))

(defn transform-tei-handler [bin-path]
  (fn [request]
    (fs/with-temp-dir [out-dir {:prefix "transform-tei-"}]
      (let [tempfile (get-in request [:params "file" :tempfile])
            out-path (fs/path out-dir "out")
            cmd [bin-path tempfile out-path]
            {:keys [exit err]} (apply shell {:continue true :err :string} cmd)]
        (if (zero? exit)
          (do
            ;; Move the output into the input `tempfile` because it's
            ;; being tracked for deletion by ring.middleware.multipart-params.temp-file
            ;; Very cheesey, but effective
            (fs/move out-path tempfile {:replace-existing true})
            {:status 200
             :body tempfile})
          {:status 500
           :body (str "Failed transform (exit code " exit "): " err)})))))

(def transform-tei-handlers
  (into {}
        (map (juxt fs/file-name transform-tei-handler))
        (fs/list-dir "bin")))

(defn handler [request]
  (let [{:keys [request-method uri]} request
        xf-handler (transform-tei-handlers (subs uri 1))]
    (cond
      (nil? xf-handler)
      {:status 404
       :body (str "Supported transform paths: "
                  (->> (keys transform-tei-handlers)
                       (map #(str "/" %))
                       (str/join ", ")))}

      (not= request-method :post)
      {:status 405 :body "Method not allowed"}

      (nil? (get-in request [:params "file" :tempfile]))
      {:status 400 :body "Missing a multipart file"}

      :else
      (xf-handler request))))

(def app
  (-> handler
      wrap-params
      (wrap-multipart-params {:store (tf/temp-file-store {;; 1 min
                                                          :expires-in 60})})))

(defn -main [& _args]
  (run-jetty app {:join? false :port 7979}))
